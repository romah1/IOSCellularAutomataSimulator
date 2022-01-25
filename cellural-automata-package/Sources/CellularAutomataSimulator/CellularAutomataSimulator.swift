public protocol CellularAutomata {
    associatedtype State: CellularAutomataState

    /// Возвращает новое состояние поля после n поколений
    /// - Parameters:
    ///   - state: Исходное состояние поля
    ///   - generations: Количество симулирвемых поколений
    /// - Returns:
    ///   - Новое состояние после симуляции
    func simulate(_ state: State, generations: UInt) throws -> State
}

public protocol CellularAutomataState {
    associatedtype Cell
    associatedtype SubState: CellularAutomataState

    /// Конструктор пустого поля
    init()

    /// Квадрат представляемой области в глобальных координатах поля
    /// Присвоение нового значение обрезая/дополняя поле до нужного размера
    var viewport: Rect { get set }

    /// Значение конкретной ячейки в точке, заданной в глобальных координатах.
    subscript(_: Point) -> Cell { get set }
    /// Значение поля в прямоугольнике, заданном в глобальных координатах.
    subscript(_: Rect) -> SubState { get set }

    /// Меняет origin у viewport
    mutating func translate(toPoint: Point)
}

public struct Size: Equatable {
    public let width: Int
    public let height: Int
    public init(width: Int, height: Int) {
        guard width >= 0 && height >= 0 else { fatalError() }
        self.width = width
        self.height = height
    }
    public static func + (lhs: Size, rhs: Size) -> Size {
        return Size(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    public static func - (lhs: Size, rhs: Size) -> Size {
        return Size(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    public static func == (lhs: Size, rhs: Size) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
}

public struct Point: Equatable {
    public let x: Int
    public let y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    public static var zero: Point { Point(x: 0, y: 0) }
    public static func + (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    public static func - (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    public static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

public struct Rect: Equatable, Sequence {
    public let origin: Point
    public let size: Size
    public init(origin: Point, size: Size = Size(width: 1, height: 1)) {
        self.origin = origin
        self.size = size
    }
    public var originEnd: Point {
        Point(x: origin.x + size.width - 1, y: origin.y + size.height - 1)
    }
    public static func == (lhs: Rect, rhs: Rect) -> Bool {
        lhs.origin == rhs.origin && lhs.size == rhs.size
    }

    public func intersect(_ other: Rect) -> Rect? {
        let x = Swift.max(other.origin.x, self.origin.x)
        let y = Swift.max(other.origin.y, self.origin.y)
        let width = Swift.min(other.originEnd.x, self.originEnd.x) - x + 1
        let height = Swift.min(other.originEnd.y, self.originEnd.y) - y + 1
        if width <= 0 || height <= 0 {
            return nil
        }
        return Rect(
            origin: Point(x: x, y: y),
            size: Size(width: width, height: height)
        )
    }
    public func contains(_ point: Point) -> Bool {
        self.intersect(Rect(origin: point)) == nil ? false : true
    }
    public func makeIterator() -> RectIterator {
        return RectIterator(self)
    }
}

public class RectIterator: IteratorProtocol {
    var curPoint: Point
    let rect: Rect
    init(_ rect: Rect) {
        self.rect = rect
        self.curPoint = rect.origin
    }
    public func next() -> Point? {
        defer {
            if self.curPoint.x < self.rect.originEnd.x {
                self.curPoint = self.curPoint + Point(x: 1, y: 0)
            } else {
                self.curPoint = Point(x: self.rect.origin.x, y: self.curPoint.y + 1)
            }
        }
        return self.rect.contains(self.curPoint) ? curPoint : nil
    }
}

public enum BinaryCell: UInt8, CustomStringConvertible {
    case inactive = 0
    case active = 1
    public var description: String {
        self == .active ? ".active" : ".inactive"
    }
}
