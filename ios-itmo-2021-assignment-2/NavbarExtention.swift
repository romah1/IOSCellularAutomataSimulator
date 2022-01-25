import Foundation
import UIKit
import CellularAutomataSimulator

extension MainScreenViewController {
    var navbarMenu: UIMenu {
        let isGameOfLifeSelected = self.userDataManager.userDefaultsIsTwoDimentionAutomata
        let isSquareCellSelected = self.userDataManager.userDefaultsFieldCellType == .square
        let menuItems: [UIMenuElement] = [
            UIMenu(
                title: "Select automata",
                options: .singleSelection,
                children: [
                    UIAction(title: "Game of Life", state: isGameOfLifeSelected ? .on : .off) { _ in
                        self.userDataManager.userDefaultsIsTwoDimentionAutomata = true
                    },
                    UIAction(title: "1D Automata", state: isGameOfLifeSelected ? .off : .on) { _ in
                        self.showSelectCodeForElementaryAutomataPopup()
                    }
                ]
            ),
            UIMenu(
                title: "Select cells type",
                options: .singleSelection,
                children: [
                    UIAction(title: "Squares", state: isSquareCellSelected ? .on : .off) { _ in
                        self.userDataManager.userDefaultsFieldCellType = .square
                        self.celluralAutomataUIView.cellMode = .square
                    },
                    UIAction(title: "Circles", state: isSquareCellSelected ? .off : .on) { _ in
                        self.userDataManager.userDefaultsFieldCellType = .circle
                        self.celluralAutomataUIView.cellMode = .circle
                    }
                ]
            ),
            UIMenu(
                title: "Select color theme",
                options: .singleSelection,
                children: [
                    UIAction(
                        title: "Light",
                        state: self.userDataManager.userDefaulsLastSelectedColorTheme == .light ? .on : .off
                    ) { _ in
                        self.userDataManager.userDefaulsLastSelectedColorTheme = .light
                        self.switchToCurrentThemeMode()
                    },
                    UIAction(
                        title: "Dark",
                        state: self.userDataManager.userDefaulsLastSelectedColorTheme == .dark ? .on : .off
                    ) { _ in
                        self.userDataManager.userDefaulsLastSelectedColorTheme = .dark
                        self.switchToCurrentThemeMode()
                    },
                    UIAction(
                        title: "Sync with OS",
                        state: self.userDataManager.userDefaulsLastSelectedColorTheme == .unspecified ? .on : .off
                    ) { _ in
                        self.userDataManager.userDefaulsLastSelectedColorTheme = .unspecified
                        self.switchToCurrentThemeMode()
                    }
                ]
            ),
            UIAction(title: "Change field size") { _ in
                self.showChangeFieldSizePopup()
            },
            UIAction(title: "Clear field", attributes: .destructive) { _ in
                self.showClearFieldPopup()
            },
            UIAction(title: "Back to launch screen") { _ in
                self.dismiss(animated: true)
            }
        ]
        return UIMenu(children: menuItems)
    }
    func showSelectCodeForElementaryAutomataPopup() {
        let inputCodeAlert = UIAlertController(title: "Input code", message: nil, preferredStyle: .alert)
        inputCodeAlert.addTextField { textField in
            textField.placeholder = "Code"
            textField.keyboardType = .numberPad
        }
        inputCodeAlert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            guard let textFields = inputCodeAlert.textFields else {
                return
            }
            if let newCodeStr = textFields[0].text {
                if let newCode = UInt8(newCodeStr) {
                    self.userDataManager.userDefaultsElementaryAutomataCode = newCode
                    self.elementaryAutomata = ElementaryCelluralAutomata(
                        ruleCode: UInt8(newCode)
                    )
                    self.userDataManager.userDefaultsIsTwoDimentionAutomata = false
                }
            }
        })
        inputCodeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        self.present(inputCodeAlert, animated: true)
    }
    func showChangeFieldSizePopup() {
        let changeSizeAlert = UIAlertController(title: "Change field size", message: nil, preferredStyle: .alert)
        changeSizeAlert.addTextField {textField in
            textField.placeholder = "Width"
            textField.keyboardType = .numberPad
        }
        changeSizeAlert.addTextField {textField in
            textField.placeholder = "Height"
            textField.keyboardType = .numberPad
        }
        changeSizeAlert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            guard let textFields = changeSizeAlert.textFields else {
                return
            }
            if let newWidthStr = textFields[0].text,
               let newHeightStr = textFields[1].text {
                if let newWidth = Int(newWidthStr),
                   let newHeight = Int(newHeightStr) {
                    self.scrollView.zoomScale = 1.0
                    self.celluralAutomataUIView.size = Size(width: newWidth, height: newHeight)
                    self.redrawCelluralAutomataUIView()
                } else {
                }
            }
        })
        changeSizeAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel) { _ in }
        )
        self.present(changeSizeAlert, animated: true)
    }
    func showClearFieldPopup() {
        let clearAlert = UIAlertController(
            title: "Clear field",
            message: "Field will be cleared.",
            preferredStyle: .alert
        )
        clearAlert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            self.clearAllField()
        })
        clearAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        self.present(clearAlert, animated: true)
    }
    func clearAllField() {
        self.scrollView.zoomScale = 1.0
        self.celluralAutomataUIView.state = TwoDimentionCelluralAutomataState()
        if let navItems = self.navbar.items {
            navItems[0].title = "Empty State"
        }
    }
    func setNavbarItemsInPausedMode(animated: Bool = true, withNewTitle title: String? = nil) {
        if title != nil {
            self.controllerSettings.currentStateTitle = title ?? ""
        }
        let navItem = UINavigationItem(title: self.controllerSettings.currentStateTitle)
        let ellipsis = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            menu: self.navbarMenu
        )
        navItem.rightBarButtonItem = ellipsis
        self.navbar.setItems([navItem], animated: animated)
    }
    func setNavbarItemsInEditMode() {
        let navItem = UINavigationItem()
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil,
            action: #selector(self.finishEditing)
        )
        navItem.rightBarButtonItem = done
        self.navbar.setItems([navItem], animated: true)
    }
    func setNavbarInCurrentMode() {
        if self.controllerSettings.mode == .pause {
            self.setNavbarItemsInPausedMode()
        } else if self.controllerSettings.mode == .edit {
            self.setNavbarItemsInEditMode()
        }
    }
}
