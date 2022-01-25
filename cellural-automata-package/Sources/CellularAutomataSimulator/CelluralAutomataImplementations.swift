import Foundation
import XCTest

extension Array where Element == [BinaryCell] {
    subscript(_ point: Point) -> BinaryCell {
        get { self[point.y][point.x] }
        set { self[point.y][point.x] = newValue }
    }
}

public class TwoDimentionCelluralAutomataState: CellularAutomataState, Equatable, CustomStringConvertible {
    public typealias Cell = BinaryCell
    public typealias SubState = TwoDimentionCelluralAutomataState
    public fileprivate(set) var field: [[Cell]]
    public fileprivate(set) var curOrigin: Point
    public required init() {
        self.field = []
        self.curOrigin = Point.zero
    }
    public init(_ substate: SubState) {
        self.field = substate.field
        self.curOrigin = substate.curOrigin
    }
    public init(field: [[Cell]], origin: Point = Point.zero) {
        self.field = field
        self.curOrigin = origin
    }
    public var viewport: Rect {
        get {
            Rect(
                origin: self.curOrigin,
                size: Size(width: (self.field.last ?? []).count, height: self.field.count)
            )
        }
        set {
            var newField: [[Cell]] = Array(
                repeating: Array(repeating: .inactive, count: newValue.size.width),
                count: newValue.size.height
            )
            if let intersectionRect = newValue.intersect(self.viewport) {
                for intersectionPoint in intersectionRect {
                    let newFieldIndexPoint = intersectionPoint - newValue.origin
                    newField[newFieldIndexPoint] = self[intersectionPoint]
                }
            }
            self.field = newField
            self.curOrigin = newValue.origin
        }
    }
    public subscript(_ point: Point) -> Cell {
        get {
            self.viewport.contains(point) ? field[point - self.curOrigin] : .inactive
        }
        set {
            if self.viewport.contains(point) {
                self.field[point - self.curOrigin] = newValue
            }
        }
    }
    public subscript(_ rect: Rect) -> SubState {
        get {
            let res = SubState(self)
            res.viewport = rect
            return res
        }
        set {
            for point in rect {
                self[point] = newValue[point]
            }
        }
    }
    public func translate(toPoint: Point) {
        self.viewport = Rect(origin: toPoint, size: self.viewport.size)
    }
    var prettyField: String {
        self.field.map { cellRow in
            cellRow.map { $0 == .active ? "🤡" : "☠️" }.joined()
        }.joined(separator: "\n")
    }
    public var description: String {
        "{ field: \(self.field), origin: \(self.curOrigin) }"
    }
    public static func == (lhs: TwoDimentionCelluralAutomataState, rhs: TwoDimentionCelluralAutomataState) -> Bool {
        lhs.curOrigin == rhs.curOrigin && lhs.field == rhs.field
    }
}

public class ElementaryCelluralAutomataState: TwoDimentionCelluralAutomataState {
    typealias SubState = ElementaryCelluralAutomataState
    required init() {
        super.init()
    }
    init(_ substate: SubState) {
        super.init(field: substate.field, origin: substate.curOrigin)
    }
    init(code: UInt8, length: UInt = 8, origin: Point = Point.zero) {
        super.init(
            field: [ElementaryCelluralAutomataState.codeToBinaryCellArr(
                            code: code,
                            length: length
            )],
            origin: origin
        )
    }
    override init(field: [[Cell]], origin: Point = Point.zero) {
        super.init(field: field, origin: origin)
    }
    static func codeToBinaryCellArr(code: UInt8, length: UInt) -> [Cell] {
        var result: [Cell] = []
        var curCode = code
        for _ in 1...length {
            result.append(curCode % 2 == 0 ? .inactive : .active)
            curCode /= 2
        }
        return result.reversed()
    }
}

public class ElementaryCelluralAutomata: CellularAutomata {
    typealias Cell = BinaryCell
    public typealias State = TwoDimentionCelluralAutomataState
    private var ruleCode: UInt8
    public init(ruleCode: UInt8 = 30) {
        self.ruleCode = ruleCode
    }
    public func simulate(_ state: State, generations: UInt) throws -> State {
        let result = State(state)
        for _ in 0..<generations {
            result.viewport = Rect(
                origin: result.curOrigin - Point(x: 1, y: 0),
                size: result.viewport.size + Size(width: 2, height: 1)
            )
            guard result.viewport.size.height >= 2 else {
                return result
            }
            let curGenerationState = result.field[result.field.count - 2]
            for idx in 0..<curGenerationState.count {
                let left = idx != 0 ? curGenerationState[idx - 1] : .inactive
                let right = idx != curGenerationState.count - 1 ? curGenerationState[idx + 1] : .inactive
                result.field[result.field.count - 1][idx] = self.getNewCellValue(
                    left,
                    curGenerationState[idx],
                    right
                )
            }
        }
        return result
    }
    private static func getNthBit(code: UInt8, bitN: UInt8) -> UInt8 {
        (code >> bitN) & 1
    }
    private func getRuleBit(ruleNumber: UInt8) -> UInt8 {
        ElementaryCelluralAutomata.getNthBit(code: self.ruleCode, bitN: ruleNumber)
    }
    private func getNewCellValue(_ cell1: Cell, _ cell2: Cell, _ cell3: Cell) -> Cell {
        let num = (cell1.rawValue << 2) + (cell2.rawValue << 1) + cell3.rawValue
        return getRuleBit(ruleNumber: num) == 1 ? .active : .inactive
    }
}

public class TwoDimentionCelluralAutomata: CellularAutomata {
    typealias Cell = BinaryCell
    public typealias State = TwoDimentionCelluralAutomataState
    public init() {}
    public func simulate(_ state: State, generations: UInt) throws -> State {
        var curGeneration = state
        for _ in 0..<generations {
            let nextGeneration = State(curGeneration)
            for pointInExtendedField in Rect(
                origin: curGeneration.viewport.origin - Point(x: 1, y: 1),
                size: curGeneration.viewport.size + Size(width: 2, height: 2)
            ) {
                let newValue = self.getNewCellValue(point: pointInExtendedField, state: curGeneration)
                if newValue == .active {
                    self.ensurePointIncluded(generation: nextGeneration, point: pointInExtendedField)
                }
                nextGeneration[pointInExtendedField] = newValue
            }
            curGeneration = nextGeneration
        }
        return curGeneration
    }
    private func ensurePointIncluded(generation: State, point: Point) {
        var newX = generation.curOrigin.x
        var newY = generation.curOrigin.y
        var newWidth = generation.viewport.size.width
        var newHeight = generation.viewport.size.height
        if point.x < generation.curOrigin.x {
            newX = point.x
            newWidth += 1
        } else if point.x > generation.viewport.originEnd.x {
            newWidth += 1
        } else if point.y < generation.curOrigin.y {
            newY = point.y
            newHeight += 1
        } else if point.y > generation.viewport.originEnd.y {
            newHeight += 1
        }
        generation.viewport = Rect(
            origin: Point(x: newX, y: newY),
            size: Size(width: newWidth, height: newHeight)
        )
    }
    private func countNeighbours(point: Point, state: State) -> Int {
        var res = 0
        for shiftY in -1...1 {
            for shiftX in -1...1 {
                guard !(shiftY == 0 && shiftX == 0) else {
                    continue
                }
                res += Int(state[point + Point(x: shiftX, y: shiftY)].rawValue)
            }
        }
        return res
    }
    private func getNewCellValue(point: Point, state: State) -> Cell {
        let neighboursAmount = countNeighbours(point: point, state: state)
        if state[point] == .active && (neighboursAmount == 2 || neighboursAmount == 3) {
            return .active
        } else if state[point] == .inactive && neighboursAmount == 3 {
            return .active
        } else {
            return .inactive
        }
    }
}
