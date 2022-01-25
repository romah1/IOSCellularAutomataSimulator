import Foundation
import UIKit
import CellularAutomataSimulator

class UISelectFieldView: UIView {
    private var isInnerTap: Bool
    private var initialCenter: CGPoint
    let selectBlockSideSize: CGFloat
    private var offset: CGFloat
    private func updateOffset() {
        self.offset = sqrt(min(self.frame.width, self.frame.height)) * 1.5
    }
    var selectedContentRect: Rect {
        get {
            Rect(
                origin: Point(
                    x: Int(self.frame.origin.x / self.selectBlockSideSize),
                    y: Int(self.frame.origin.y / self.selectBlockSideSize)
                ),
                size: Size(
                    width: Int(self.frame.width / self.selectBlockSideSize),
                    height: Int(self.frame.height / self.selectBlockSideSize)
                )
            )
        }
        set {
            guard let superview = self.superview else {
                return
            }
            let newRect = CGRect(
                x: CGFloat(newValue.origin.x) * self.selectBlockSideSize,
                y: CGFloat(newValue.origin.y) * self.selectBlockSideSize,
                width: CGFloat(newValue.size.width) * self.selectBlockSideSize,
                height: CGFloat(newValue.size.height) * self.selectBlockSideSize
            )
            self.frame = newRect.intersection(superview.frame)
        }
    }
    init(selectBlockSideSize: CGFloat) {
        self.isInnerTap = false
        self.initialCenter = CGPoint.zero
        self.selectBlockSideSize = selectBlockSideSize
        self.offset = 10
        super.init(frame: CGRect(
            origin: .zero,
            size: CGSize(
                width: self.selectBlockSideSize,
                height: self.selectBlockSideSize
            )
        ))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.longPressHandler)
        )
        longPressGestureRecognizer.minimumPressDuration = 0.0
        self.addGestureRecognizer(longPressGestureRecognizer)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 5
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        let tapLocation = sender.location(in: self.superview)
        
        if sender.state == .began {
            self.initialCenter = tapLocation
            self.isInnerTap = checkIfInnerTap(tapLocation: tapLocation)
        } else if sender.state == .changed {
            if self.isInnerTap {
                self.handleInnerTap(tapLocation: tapLocation)
            } else {
                self.handleSelectFieldResize(tapLocation: tapLocation)
            }
        } else {
            self.handleEndLongPressInteraction()
        }
        self.initialCenter = tapLocation
    }
    func checkIfInnerTap(tapLocation: CGPoint) -> Bool {
        self.initialCenter = tapLocation
        let xFromSelectView = tapLocation.x - self.frame.minX
        let yFromSelectView = tapLocation.y - self.frame.minY
        if (self.offset < xFromSelectView && xFromSelectView < self.frame.width - self.offset) &&
            (self.offset < yFromSelectView && yFromSelectView < self.frame.height - self.offset) {
            return true
        } else {
            return false
        }
    }
    func handleInnerTap(tapLocation: CGPoint) {
        guard let superview = self.superview else {
            return
        }
        let rescaledTapLocation = tapLocation
        var newRect = self.frame
        newRect.origin = CGPoint(
            x: newRect.minX + rescaledTapLocation.x - self.initialCenter.x,
            y: newRect.minY + rescaledTapLocation.y - self.initialCenter.y
        )
        self.frame = newRect.intersection(superview.bounds)
    }
    func handleSelectFieldResize(tapLocation: CGPoint) {
        var newRect = self.frame
        if self.frame.minX + self.frame.width - self.offset <= tapLocation.x {
            let newWidth = tapLocation.x - self.frame.minX
            newRect.size.width = self.checkWidth(newWidth) ? newWidth : self.widthToBound(newWidth)
        } else if tapLocation.x <= self.frame.minX + self.offset {
            if tapLocation.x >= 0 {
                let newWidth = self.frame.maxX - tapLocation.x
                newRect.size.width = self.checkWidth(newWidth) ? newWidth : self.widthToBound(newWidth)
                if newRect.width != self.frame.width {
                    newRect.origin.x = tapLocation.x
                }
            }
        }

        if self.frame.minY + self.frame.height - self.offset <= tapLocation.y {
            let newHeight = tapLocation.y - self.frame.minY
            newRect.size.height = self.checkHeight(newHeight) ? newHeight : self.heightToBound(newHeight)
        } else if tapLocation.y <= self.frame.origin.y + self.offset {
            if tapLocation.y >= 0 {
                let newHeight = self.frame.maxY - tapLocation.y
                newRect.size.height = self.checkHeight(newHeight) ? newHeight : self.heightToBound(newHeight)
                if newRect.height != self.frame.height {
                    newRect.origin.y = tapLocation.y
                }
            }
        }
        self.frame = newRect.intersection(self.superview!.bounds)
    }
    func handleEndLongPressInteraction() {
        self.updateOffset()
        let newFrame = CGRect(
            x: self.roundToSideLength(val: self.frame.minX),
            y: self.roundToSideLength(val: self.frame.minY),
            width: self.roundToSideLength(val: self.frame.width),
            height: self.roundToSideLength(val: self.frame.height)
        )
        UIView.animate(withDuration: 0.2) {
            self.frame = newFrame
        }
    }
    func checkWidth(_ val: CGFloat) -> Bool {
        guard let superview = self.superview else {
            return false
        }
        let trailingBound = superview.bounds.maxX - self.bounds.minX
        return self.selectBlockSideSize <= val && val <= trailingBound
    }
    func widthToBound(_ val: CGFloat) -> CGFloat {
        guard let superview = self.superview else {
            return 0
        }
        return val < self.selectBlockSideSize ? self.selectBlockSideSize : superview.bounds.width
    }
    func checkHeight(_ val: CGFloat) -> Bool {
        guard let superview = self.superview else {
            return false
        }
        let trailingBound = superview.bounds.maxY - self.bounds.minY
        return self.selectBlockSideSize <= val && val <= trailingBound
    }
    func heightToBound(_ val: CGFloat) -> CGFloat {
        guard let superview = self.superview else {
            return 0
        }
        return val < self.selectBlockSideSize ? self.selectBlockSideSize : superview.bounds.height
    }

    func roundToSideLength(val: CGFloat) -> CGFloat {
        round(val / self.selectBlockSideSize) * self.selectBlockSideSize
    }
}
