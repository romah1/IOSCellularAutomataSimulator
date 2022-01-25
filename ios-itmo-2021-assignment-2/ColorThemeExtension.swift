import Foundation
import UIKit

extension MainScreenViewController {
    func switchToCurrentThemeMode() {
        let controllers = [
            self,
            self.automataSnapshotLibrary,
            self.automataStateLibrary
        ]
        let newStyle: UIUserInterfaceStyle
        if self.userDataManager.userDefaulsLastSelectedColorTheme == .unspecified {
            newStyle = self.traitCollection.userInterfaceStyle
        } else {
            newStyle = self.userDataManager.userDefaulsLastSelectedColorTheme
        }
        for controller in controllers {
            if let controller = controller {
                controller.overrideUserInterfaceStyle = newStyle
            }
        }
        self.selectFieldView.layer.borderColor = UIColor(
            named: "selectFieldColor"
        )?.resolvedColor(with: self.traitCollection).cgColor
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
