import Foundation
import UIKit
import CellularAutomataSimulator

extension MainScreenViewController {
    @objc func finishEditing() {
        guard self.controllerSettings.mode == .edit else {
            return
        }
        self.controllerSettings.mode = .pause
        self.selectFieldView.isHidden = true
        self.selectFieldView.frame.size = CGSize(
            width: self.selectFieldView.selectBlockSideSize,
            height: self.selectFieldView.selectBlockSideSize
        )
        self.setUIInCurrentMode()
    }
    @objc func celluralAutomataUIViewLongPress(_ sender: UILongPressGestureRecognizer) {
        let tapLocation = sender.location(in: self.celluralAutomataUIView)
        if sender.state == .began && (self.controllerSettings.mode == .pause || self.controllerSettings.mode == .edit) {
            let cellX = floor(
                tapLocation.x / self.celluralAutomataUIView.sideLength
            ) * self.celluralAutomataUIView.sideLength
            let cellY = floor(
                tapLocation.y / self.celluralAutomataUIView.sideLength
            ) * self.celluralAutomataUIView.sideLength
            if self.controllerSettings.mode == .pause || self.selectFieldView.frame.width == 0 || selectFieldView.frame.height == 0 {
                self.selectFieldView.frame.origin = CGPoint(x: cellX, y: cellY)
                self.selectFieldView.alpha = 0
                self.selectFieldView.isHidden = false
                UIView.animate(withDuration: 0.2) {
                    self.selectFieldView.alpha = 1
                }
            }
            UIView.animate(withDuration: 0.2) {
                self.selectFieldView.frame = CGRect(
                    x: cellX,
                    y: cellY,
                    width: self.selectFieldView.selectBlockSideSize,
                    height: self.selectFieldView.selectBlockSideSize
                )
            }
            self.controllerSettings.mode = .edit
            self.setUIInCurrentMode()
        } else if sender.state == .changed {
            self.selectFieldView.handleSelectFieldResize(tapLocation: tapLocation)
        } else {
            self.selectFieldView.handleEndLongPressInteraction()
        }
    }
}
