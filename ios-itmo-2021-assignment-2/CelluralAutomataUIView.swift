import UIKit
import CellularAutomataSimulator

enum CellMode {
    case circle
    case square
}

class CelluralAutomataUIView: UIView {
    var cellBorderColor: UIColor
    var cellFillColor: UIColor
    var cellBaseColor: UIColor
    var circlePad: CGFloat
    var cellMode: CellMode {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var state: TwoDimentionCelluralAutomataState {
        didSet {
            self.fitFrameSize()
        }
    }
    var size: Size {
        get {
            self.state.viewport.size
        }
        set {
            self.state.viewport = Rect(
                origin: self.state.curOrigin,
                size: newValue
            )
            self.fitFrameSize()
        }
    }
    private func fitFrameSize() {
        self.frame.size = CGSize(
            width: CGFloat(state.viewport.size.width) * self.sideLength,
            height: CGFloat(state.viewport.size.height) * self.sideLength
        )
    }
    let sideLength: CGFloat = 30.0
    override class var layerClass: AnyClass {
        CATiledLayer.self
    }
    var tiledLayer: CATiledLayer {
        if let layer = self.layer as? CATiledLayer {
            return layer
        }
        fatalError("Layer is not CATiledLayer")
    }
    override var contentScaleFactor: CGFloat {
        didSet {
            super.contentScaleFactor = 1
        }
    }
    init(state: TwoDimentionCelluralAutomataState = TwoDimentionCelluralAutomataState()) {
        self.state = state
        self.cellMode = .square
        self.circlePad = 2
        guard
            let cellBorderColor = UIColor(named: "automataCellBorderColor"),
            let cellFillColor = UIColor(named: "automataCellFillColor"),
            let cellBaseColor = UIColor(named: "automataCellBaseColor") else {
                fatalError("Missing cell color")
            }
        self.cellBorderColor = cellBorderColor
        self.cellFillColor = cellFillColor
        self.cellBaseColor = cellBaseColor
        super.init(frame: CGRect(
            x: 0,
            y: 0,
            width: CGFloat(self.state.viewport.size.width) * self.sideLength,
            height: CGFloat(self.state.viewport.size.height) * self.sideLength
        ))
        self.setupTiledLayer()
    }

    required init?(coder: NSCoder) { // why not use override here?
        fatalError("Not implemented")
    }
    func resize(newWidthCells: Int, newHeightCells: Int) {
        self.frame.size = CGSize(
            width: CGFloat(newWidthCells) * self.sideLength,
            height: CGFloat(newHeightCells) * self.sideLength
        )
    }
    func setupTiledLayer() {
        let scale = UIScreen.main.scale
        self.tiledLayer.contentsScale = scale
        self.tiledLayer.tileSize = CGSize(
            width: self.sideLength * scale,
            height: self.sideLength * scale
        )
    }
    func changeCellValue(point: CGPoint) {
        let row = Int(point.y / self.sideLength)
        let col = Int(point.x / self.sideLength)
        self.state[Point(x: col, y: row)] = self.state[Point(x: col, y: row)] == .active ? .inactive : .active
    }
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let cellX: Int = Int(rect.origin.x / sideLength)
        let cellY: Int = Int(rect.origin.y / sideLength)
        context?.setFillColor(
            self.state[Point(x: cellX, y: cellY)] == .active ?
                self.cellFillColor.cgColor : self.cellBaseColor.cgColor
        )
        context?.setStrokeColor(self.cellBorderColor.cgColor)
        if cellMode == .square {
            context?.fill(rect)
            context?.stroke(rect)
        } else if cellMode == .circle {
            context?.addEllipse(in: paddedRectForCircle(initialRect: rect))
            context?.drawPath(using: .fillStroke)
        }
    }
    func paddedRectForCircle(initialRect: CGRect) -> CGRect {
        CGRect(
            x: initialRect.minX + self.circlePad,
            y: initialRect.minY + self.circlePad,
            width: initialRect.width - self.circlePad * 2,
            height: initialRect.height - self.circlePad * 2
        )
    }
    func clearRect(_ rect: Rect) {
        self.state[rect] = TwoDimentionCelluralAutomataState()
    }
}
