import Foundation
import UIKit
import CellularAutomataSimulator
import SwiftUI

class AppSettings {
    var fieldPasteboard: UIPasteboard
    
    init() {
        self.fieldPasteboard = UIPasteboard.withUniqueName()
    }
}

class GlobalLibraryApi {
    private let mainURL: URL
    private let itemsURL: URL
    
    init() {
        let mainURL = URL(string: "https://itmo2021.wimag.io")
        guard let mainURL = mainURL else {
            fatalError("Can not create URL")
        }
        self.mainURL = mainURL
        self.itemsURL = self.mainURL.appendingPathComponent("items")
    }
    
    func getItems() async -> [LibraryItem]? {
        let request = URLRequest(url: self.itemsURL)
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let response = try? await URLSession(configuration: config).data(for: request)
        if let response = response {
            let items = try? JSONDecoder().decode([ResponseItem].self, from: response.0)
            if let items = items {
                let libraryItems = items.map {
                    LibraryItem(responseItem: $0)
                }
                return libraryItems
            } else {
                fatalError("Can not decode response items")
            }
        } else {
            return nil
        }
    }
    
    struct ResponseItem: Decodable, Hashable, Identifiable {
        let id: String
        let width: Int
        let height: Int
        let name: String
        let cells: [Bool]
        
        enum CodingKeys: String, CodingKey {
            case id
            case width
            case height
            case name
            case cells
        }
    }
}

extension LibraryItem {
    init(responseItem: GlobalLibraryApi.ResponseItem) {
        self.name = responseItem.name
        self.field = LibraryItem.getLibraryItemField(responseItem: responseItem)
    }
    
    private static func getLibraryItemField(responseItem: GlobalLibraryApi.ResponseItem) -> [[BinaryCell]] {
        var result = Array(
            repeating: Array(repeating: BinaryCell.inactive, count: responseItem.width),
            count: responseItem.height
        )
        for i in 0..<responseItem.height {
            for j in 0..<responseItem.width {
                let idx = i * responseItem.width + j
                if idx < responseItem.cells.count {
                    result[i][j] = responseItem.cells[idx] ? .active : .inactive
                }
            }
        }
        return result
    }
}

class UserDataManager {
    private var userSavedFileManagerDocuments: URL
    private var snapshotFileManagerDocuments: URL
    var globalLibraryData: LibraryData
    
    init() {
        let url = FileManager.default.urls(
            for: .documentDirectory,
               in: .userDomainMask
        )[0]
        self.userSavedFileManagerDocuments = url.appendingPathComponent("userSavedStates")
        self.snapshotFileManagerDocuments = url.appendingPathComponent("userSavedSnapshots")
        self.globalLibraryData = LibraryData(items: [])
        DispatchQueue.main.async {
            Task {
                self.globalLibraryData.items = await GlobalLibraryApi().getItems() ?? []
            }
        }
    }
}

extension UserDefaults {
    func reset() {
        SaveKeys.allCases.forEach {
            self.removeObject(forKey: $0.rawValue)
        }
        let userDataManager = UserDataManager()
        userDataManager.userSavedSnapshots = []
        userDataManager.userSavedAutomataStates = []
    }
}

extension UIUserInterfaceStyle: Codable {}

enum SaveKeys: String, CaseIterable {
    case isTwoDimentionAutomata
    case elementaryAutomataCode
    case isSquareCellSelected
    case selectedColorTheme
    case userSavedStates
    case userSavedSnapshots
}


extension UserDataManager {
    var userDefaultsIsTwoDimentionAutomata: Bool {
        get {
            UserDefaults.standard.bool(forKey: SaveKeys.isTwoDimentionAutomata.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SaveKeys.isTwoDimentionAutomata.rawValue)
        }
    }
    var userDefaultsElementaryAutomataCode: UInt8 {
        get {
            UInt8(UserDefaults.standard.integer(forKey: SaveKeys.elementaryAutomataCode.rawValue))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SaveKeys.elementaryAutomataCode.rawValue)
        }
    }
    var userDefaultsFieldCellType: CellMode {
        get {
            UserDefaults.standard.bool(
                forKey: SaveKeys.isSquareCellSelected.rawValue
            ) == true ? .square : .circle
        }
        set {
            UserDefaults.standard.set(newValue == .square, forKey: SaveKeys.isSquareCellSelected.rawValue)
        }
    }
    var userDefaulsLastSelectedColorTheme: UIUserInterfaceStyle {
        get {
            UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(
                forKey: SaveKeys.selectedColorTheme.rawValue
            )) ?? .light
        }
        set {
            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: SaveKeys.selectedColorTheme.rawValue
            )
        }
    }
    
    var userSavedAutomataStates: [LibraryItem] {
        get {
            if let data = try? Data(contentsOf: self.userSavedFileManagerDocuments) {
                let result = try? JSONDecoder().decode([LibraryItem].self, from: data)
                if let result = result {
                    return result
                } else {
                    fatalError("Error while decoding data")
                }
            } else {
                return []
            }
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            if let data = data {
                try? data.write(to: self.userSavedFileManagerDocuments)
            } else {
                fatalError("Can not encode data")
            }
        }
    }
    
    var userSavedSnapshots: [LibraryItem] {
        get {
            if let data = try? Data(contentsOf: self.snapshotFileManagerDocuments) {
                let result = try? JSONDecoder().decode([LibraryItem].self, from: data)
                if let result = result {
                    return result
                } else {
                    fatalError("Error while decoding data")
                }
            } else {
                return []
            }
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            if let data = data {
                try? data.write(to: self.snapshotFileManagerDocuments)
            } else {
                fatalError("Can not encode data")
            }
        }
    }
}

