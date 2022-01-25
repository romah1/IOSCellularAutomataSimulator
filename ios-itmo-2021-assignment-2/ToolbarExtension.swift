import Foundation
import UIKit
import CellularAutomataSimulator

extension MainScreenViewController {
    func setToolbarInCurrentMode() {
        if self.controllerSettings.mode == .pause || self.controllerSettings.mode == .play {
            self.setToolbarToPausePlayMode()
        } else if self.controllerSettings.mode == .edit {
            self.setToolbarToEditMode()
        }
    }
    @objc func writeSnapshotLongPressGestrure(_ selector: UILongPressGestureRecognizer) {
        if selector.state == .began {
            self.present(self.automataSnapshotLibrary, animated: true)
        }
    }
    func setToolbarToPausePlayMode() {
        let moveToSnapshotBtn = UIBarButtonItem(
            barButtonSystemItem: .rewind,
            target: nil,
            action: #selector(self.moveToSnapshot)
        )
        let moveToNextGenerationBtn = UIBarButtonItem(
            barButtonSystemItem: .fastForward,
            target: nil,
            action: #selector(self.moveToNextGeneration)
        )
        let composeButtonView = UIButton(type: .system, primaryAction: UIAction { _ in
            self.writeSnapshot()
        })
        composeButtonView.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        composeButtonView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(self.writeSnapshotLongPressGestrure)
            )
        )
        let composeBtn = UIBarButtonItem(customView: composeButtonView)
        let addBtn = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: nil,
            action: #selector(self.addBtnHandler)
        )
        let playPauseButton = UIBarButtonItem(
            barButtonSystemItem: self.controllerSettings.mode == .pause ? .play : .pause,
                target: nil,
                action: #selector(self.playGeneration)
            )
        if self.controllerSettings.mode == .pause {
            let chooseSpeedMenu = UIMenu(
                children: [
                    UIAction(title: "Fast", state: self.controllerSettings.currentPlaySpeed == .fast ? .on : .off) { _ in
                        self.controllerSettings.currentPlaySpeed = .fast
                        self.setToolbarInCurrentMode()
                    },
                    UIAction(title: "Normal", state: self.controllerSettings.currentPlaySpeed == .normal ? .on : .off) { _ in
                        self.controllerSettings.currentPlaySpeed = .normal
                        self.setToolbarInCurrentMode()
                    },
                    UIAction(title: "Slow", state: self.controllerSettings.currentPlaySpeed == .slow ? .on : .off) { _ in
                        self.controllerSettings.currentPlaySpeed = .slow
                        self.setToolbarInCurrentMode()
                    }
                ]
            )
            playPauseButton.menu = chooseSpeedMenu
        }
        
        toolbarItems = [
            composeBtn,
            UIBarButtonItem.flexibleSpace(),
            moveToSnapshotBtn,
            playPauseButton,
            moveToNextGenerationBtn,
            UIBarButtonItem.flexibleSpace(),
            addBtn
        ]
        if self.controllerSettings.mode == .play {
            composeBtn.isEnabled = false
            moveToSnapshotBtn.isEnabled = false
            moveToNextGenerationBtn.isEnabled = false
            addBtn.isEnabled = false
        }
        self.toolbar.setItems(toolbarItems, animated: true)
    }
    @objc func addBtnHandler() {
        self.automataStateLibrary.libraryData.items = self.userDataManager.userSavedAutomataStates
        self.present(self.automataStateLibrary, animated: true)
    }
    func setToolbarToEditMode() {
        toolbarItems = [
            UIBarButtonItem.fixedSpace(5),
            UIBarButtonItem(
                barButtonSystemItem: .save,
                target: nil,
                action: #selector(self.showInputNamePopup)
            ),
            UIBarButtonItem.flexibleSpace(),
            UIBarButtonItem(
                image: UIImage(systemName: "rotate.left"),
                style: .plain,
                target: nil,
                action: #selector(self.rotateSelectedFieldLeft)
            ),
            UIBarButtonItem.fixedSpace(10),
            UIBarButtonItem(
                image: UIImage(systemName: "rotate.right"),
                style: .plain,
                target: nil,
                action: #selector(self.rotateSelectedField)
            ),
            UIBarButtonItem.flexibleSpace(),
            UIBarButtonItem(
                systemItem: .action,
                primaryAction: nil,
                menu: UIMenu(
                    children: [
                        UIAction(title: "Cut", image: UIImage(systemName: "scissors")) { _ in
                            self.copySelectedToClipboard()
                            self.clearSelectedField()
                        },
                        UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                            self.copySelectedToClipboard()
                        },
                        UIAction(title: "Paste", image: UIImage(systemName: "doc.on.clipboard")) { _ in
                            self.pasteFieldFromClipboard()
                        },
                        UIAction(title: "Paste Live", image: UIImage(systemName: "doc.on.clipboard.fill")) { _ in
                            self.pasteLiveCellsFromClipboard()
                        },
                        UIAction(title: "Clear", image: UIImage(systemName: "clear")) { _ in
                            self.clearSelectedField()
                        }
                    ].reversed()
                )
            ),
            UIBarButtonItem.fixedSpace(5)
        ]
        self.toolbar.setItems(toolbarItems, animated: true)
    }
    @objc func copySelectedToClipboard() {
        let selectedRect = self.selectFieldView.selectedContentRect
        let selectedField = self.celluralAutomataUIView.state[selectedRect].field
        self.copyFieldToClipboard(field: selectedField)
    }
    @objc func pasteFieldFromClipboard() {
        let field = self.readFieldFromClipboard()
        let selectedRect = self.selectFieldView.selectedContentRect
        self.celluralAutomataUIView.state[selectedRect] = TwoDimentionCelluralAutomataState(
            field: field,
            origin: selectedRect.origin
        )
        self.redrawCelluralAutomataUIView()
    }
    @objc func pasteLiveCellsFromClipboard() {
        let copiedField = self.readFieldFromClipboard()
        let selectedRect = self.selectFieldView.selectedContentRect
        for point in selectedRect {
            let cellCoords = point - selectedRect.origin
            guard
                cellCoords.y < copiedField.count &&
                cellCoords.x < copiedField[cellCoords.y].count else {
                continue
            }
            if copiedField[cellCoords.y][cellCoords.x] == .active {
                self.celluralAutomataUIView.state[point] = .active
            }
        }
        self.redrawCelluralAutomataUIView()
    }
    @objc func rotateSelectedFieldLeft() {
        self.rotateSelectedField(toLeft: true)
    }
    @objc func rotateSelectedField(toLeft: Bool = false) {
        let selectedRect = self.selectFieldView.selectedContentRect
        let selectedField = self.celluralAutomataUIView.state[selectedRect].field
        let newField = toLeft ? rotateFieldLeft(arr: selectedField) : rotateFieldRight(arr: selectedField)
        let newRect = Rect(
            origin: Point(x: selectedRect.origin.x, y: selectedRect.origin.y),
            size: Size(
                width: selectedRect.size.height,
                height: selectedRect.size.width
            )
        )
        self.clearSelectedField()
        self.pasteField(rect: newRect, field: newField)
        UIView.animate(withDuration: 0.2) {
            self.selectFieldView.selectedContentRect = newRect
        }
    }
    func rotateFieldRight(arr: [[BinaryCell]]) -> [[BinaryCell]] {
        var res = Array(
            repeating: Array(repeating: BinaryCell.inactive, count: arr.count),
            count: (arr.last ?? []).count
        )
        var newRow = 0
        for oldCol in 0..<(arr.last ?? []).count {
            var newCol = 0
            for oldRow in (0..<arr.count).reversed() {
                res[newRow][newCol] = arr[oldRow][oldCol]
                newCol += 1
            }
            newRow += 1
        }
        return res
    }
    func rotateFieldLeft(arr: [[BinaryCell]]) -> [[BinaryCell]] {
        var res = Array(
            repeating: Array(repeating: BinaryCell.inactive, count: arr.count),
            count: (arr.first ?? []).count
        )
        var newRow = 0
        for oldCol in (0..<(arr.last ?? []).count).reversed() {
            var newCol = 0
            for oldRow in 0..<arr.count {
                res[newRow][newCol] = arr[oldRow][oldCol]
                newCol += 1
            }
            newRow += 1
        }
        return res
    }
    @objc func moveToNextGeneration() {
        let isTwoDimentionAutomata = UserDefaults.standard.bool(forKey: "isTwoDimentionAutomata")
        var newState: TwoDimentionCelluralAutomataState?
        if isTwoDimentionAutomata {
            newState = try? twoDimentionAutomata.simulate(self.celluralAutomataUIView.state, generations: 1)
        } else {
            newState = try? elementaryAutomata.simulate(self.celluralAutomataUIView.state, generations: 1)
        }
        self.celluralAutomataUIView.state = newState ?? TwoDimentionCelluralAutomataState()
        self.redrawCelluralAutomataUIView()
    }
    @objc func moveToSnapshot() {
        let snapshots = self.automataSnapshotLibrary.libraryData
        let last = snapshots.items.popLast()
        if let last = last {
            self.celluralAutomataUIView.state = TwoDimentionCelluralAutomataState(field: last.field)
            self.redrawCelluralAutomataUIView()
        }
    }
    @objc func writeSnapshot() {
        let snapshots = self.automataSnapshotLibrary.libraryData
        let snapshot = LibraryItem(
            name: "User Snapshot \(snapshots.items.count)",
            field: self.celluralAutomataUIView.state.field
        )
        snapshots.items.append(snapshot)
        self.userDataManager.userSavedSnapshots.append(snapshot)
    }
    @objc func playGeneration() {
        self.controllerSettings.mode = self.controllerSettings.mode == .play ? .pause : .play
        self.setToolbarInCurrentMode()
        if self.controllerSettings.mode == .play {
            var speed: TimeInterval
            switch self.controllerSettings.currentPlaySpeed {
            case .slow:
                speed = 0.8
            case .normal:
                speed = 0.5
            case .fast:
                speed = 0.2
            }
            self.playButtonTimer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { _ in
                self.moveToNextGeneration()
            }
            self.playButtonTimer.fire()
        } else {
            self.playButtonTimer.invalidate()
        }
    }
    func saveSelectedFieldToLibrary(withName name: String) {
        let selectedField = self.celluralAutomataUIView.state[self.selectFieldView.selectedContentRect].field
        let item = LibraryItem(
            name: name,
            field: selectedField
        )
        self.userDataManager.userSavedAutomataStates.append(item)
//        self.automataStateLibrary.libraryData.items.append(LibraryItem(name: name, field: selectedField))
    }
    @objc func showInputNamePopup() {
        let inputNameAlert = UIAlertController(
            title: "Input name",
            message: nil,
            preferredStyle: .alert
        )
        inputNameAlert.addTextField { textField in
            textField.placeholder = "Name"
        }
        inputNameAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            guard let textFields = inputNameAlert.textFields else {
                return
            }
            self.saveSelectedFieldToLibrary(withName: textFields[0].text ?? "")
        }))
        inputNameAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel) { _ in }
        )
        self.present(inputNameAlert, animated: true)
    }
    func pasteField(rect: Rect, field: [[BinaryCell]]) {
        self.celluralAutomataUIView.state[rect] = TwoDimentionCelluralAutomataState(
            field: field,
            origin: rect.origin
        )
    }
    @objc func clearSelectedField() {
        let rectToClear = self.selectFieldView.selectedContentRect
        self.pasteField(rect: rectToClear, field: [])
        self.redrawCelluralAutomataUIView()
    }
}
