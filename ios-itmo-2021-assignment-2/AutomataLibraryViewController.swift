import Foundation
import SwiftUI
import UIKit
import CellularAutomataSimulator
import SwiftUI

struct CellularAutomataView: UIViewRepresentable {
    var state: TwoDimentionCelluralAutomataState
    
    func makeUIView(context: Context) -> some UIView {
        CelluralAutomataUIView(state: state)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

class AutomataLibraryViewController: UIViewController {
    var libraryData: LibraryData
    private var navTitle: String
    private let fieldPasteboard: UIPasteboard
    private let userDataManager: UserDataManager
    private let automataField: CelluralAutomataUIView!
    private var controller: UIHostingController<LibraryView>!
    private var navbar: UINavigationBar!
    
    init(
        title: String,
        automataField: CelluralAutomataUIView,
        fieldPasteboard: UIPasteboard,
        userDataManager: UserDataManager
    ) {
        self.navTitle = title
        self.userDataManager = userDataManager
        self.libraryData = LibraryData(items: self.userDataManager.userSavedAutomataStates)
        self.automataField = automataField
        self.fieldPasteboard = fieldPasteboard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setNavbar()
        self.setLibrary()
        
        NSLayoutConstraint.activate([
            self.navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.controller.view.topAnchor.constraint(equalTo: self.navbar.bottomAnchor),
            self.controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setNavbar() {
        self.navbar = UINavigationBar(frame: CGRect.zero)
        self.navbar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem()
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil,
            action: #selector(self.close)
        )
        navItem.rightBarButtonItem = done
        navItem.title = self.navTitle
        self.navbar.setItems([navItem], animated: false)
        self.view.addSubview(self.navbar)
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    private func setLibrary() {
        self.controller = UIHostingController(rootView: LibraryView(
            userDataManager: self.userDataManager,
            fieldPasteboard: self.fieldPasteboard,
            automataField: self.automataField,
            userLibraryData: self.libraryData,
            globalLibraryData: self.userDataManager.globalLibraryData
        ))
        self.addChild(self.controller)
        self.controller.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.controller.view)
        self.controller.didMove(toParent: self)
    }
}

class SnapshotLibraryViewController: UIViewController {
    var libraryData: LibraryData
    private var navTitle: String
    private let fieldPasteboard: UIPasteboard
    private let userDataManager: UserDataManager
    private let automataField: CelluralAutomataUIView!
    private var controller: UIHostingController<SnapshotLibraryView>!
    private var navbar: UINavigationBar!
    
    init(
        title: String,
        automataField: CelluralAutomataUIView,
        fieldPasteboard: UIPasteboard,
        userDataManager: UserDataManager
    ) {
        self.navTitle = title
        self.userDataManager = userDataManager
        self.libraryData = LibraryData(items: self.userDataManager.userSavedSnapshots)
        self.automataField = automataField
        self.fieldPasteboard = fieldPasteboard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setNavbar()
        self.setLibrary()
        
        NSLayoutConstraint.activate([
            self.navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.controller.view.topAnchor.constraint(equalTo: self.navbar.bottomAnchor),
            self.controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setNavbar() {
        self.navbar = UINavigationBar(frame: CGRect.zero)
        self.navbar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem()
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil,
            action: #selector(self.close)
        )
        navItem.rightBarButtonItem = done
        navItem.title = self.navTitle
        self.navbar.setItems([navItem], animated: false)
        self.view.addSubview(self.navbar)
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    private func setLibrary() {
        self.controller = UIHostingController(rootView: SnapshotLibraryView(
            userDataManager: self.userDataManager,
            fieldPasteboard: self.fieldPasteboard,
            automataField: self.automataField,
            userLibraryData: self.libraryData
        ))
        self.addChild(self.controller)
        self.controller.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.controller.view)
        self.controller.didMove(toParent: self)
    }
}

class LibraryData: ObservableObject {
    @Published var items: [LibraryItem]
    
    init(items: [LibraryItem]) {
        self.items = items
    }
}

struct SnapshotLibraryView: View {
    var userDataManager: UserDataManager
    var fieldPasteboard: UIPasteboard
    var automataField: CelluralAutomataUIView
    @ObservedObject var userLibraryData: LibraryData

    var body: some View {
        List {
            ForEach(self.userLibraryData.items,
                id: \.self
            ) { item in
                LibraryCell(
                    fieldPasteboard: self.fieldPasteboard,
                    automataField: self.automataField,
                    libraryItem: item
                ).frame(height: 250)
            }.onDelete(perform: self.deleteRow)
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        self.userLibraryData.items.remove(atOffsets: indexSet)
        self.userDataManager.userSavedSnapshots = self.userLibraryData.items
    }
}

struct LibraryView: View {
    var userDataManager: UserDataManager
    var fieldPasteboard: UIPasteboard
    var automataField: CelluralAutomataUIView
    @ObservedObject var userLibraryData: LibraryData
    @ObservedObject var globalLibraryData: LibraryData
    @State var isUserLibrarySelected = true

    var body: some View {
        NavigationView {
            List {
                ForEach(
                    self.isUserLibrarySelected ? self.userLibraryData.items : self.globalLibraryData.items,
                    id: \.self
                ) { item in
                    LibraryCell(
                        fieldPasteboard: self.fieldPasteboard,
                        automataField: self.automataField,
                        libraryItem: item
                    ).frame(height: 250)
                }.if(self.isUserLibrarySelected) {
                    $0.onDelete(perform: self.deleteRow)
                }
            }.toolbar {
                ToolbarItem(placement: .principal) {
                    GeometryReader { proxy in
                        HStack(spacing: 0) {
                            Button("Your library") {
                                self.isUserLibrarySelected = true
                            }
                            .frame(width: proxy.size.width / 2, height: 30)
                            .foregroundColor(.white)
                            .background(self.isUserLibrarySelected ? .blue : .gray)
                            .cornerRadius(6, corners: [.topLeft, .bottomLeft])
                            Button("Global library") {
                                self.isUserLibrarySelected = false
                            }
                            .frame(width: proxy.size.width / 2, height: 30)
                            .foregroundColor(.white)
                            .background(!self.isUserLibrarySelected ? .blue : .gray)
                            .cornerRadius(6, corners: [.topRight, .bottomRight])
                        }
                        .frame(width: proxy.size.width, height: 30)
                    }
                }
            }
        }
        
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        self.userLibraryData.items.remove(atOffsets: indexSet)
        self.userDataManager.userSavedAutomataStates = self.userLibraryData.items
    }
}

struct LibraryCell: View {
    var fieldPasteboard: UIPasteboard
    var automataField: CelluralAutomataUIView
    var libraryItem: LibraryItem
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text(libraryItem.name)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Menu(
                            content: {
                                Button("Copy", action: {
                                    self.copyFieldToClipboard(field: libraryItem.field)
                                })
                                Button("Paste", action: {
                                    self.pasteField(field: libraryItem.field)
                                })
                            },
                            label: {
                                Label("", systemImage: "ellipsis")
                            }
                        )
                    }
                }
                ScrollView([.horizontal, .vertical]) {
                    CellularAutomataView(
                        state: TwoDimentionCelluralAutomataState(field: libraryItem.field)
                    ).frame(width: 1000, height: 1000)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
    }
    
    private func copyFieldToClipboard(field: [[BinaryCell]]) {
        self.fieldPasteboard.strings = field.map { row in
            row.map { cell in
                cell == .active ? "1" : "0"
            }.joined()
        }
    }
    
    private func pasteField(field: [[BinaryCell]]) {
        self.automataField.state = TwoDimentionCelluralAutomataState(field: libraryItem.field)
        self.automataField.setNeedsDisplay()
    }
}

extension BinaryCell: Codable {}

struct LibraryItem: Hashable, Codable {
    let name: String
    let field: [[BinaryCell]]
    
    init(name: String, field: [[BinaryCell]]) {
        self.name = name
        self.field = field
    }
}

extension LibraryItem {
    static var block: LibraryItem {
        LibraryItem(
            name: "Block",
            field: Array(repeating: Array(repeating: .active, count: 2), count: 2)
        )
    }
    static var beeHive: LibraryItem {
        LibraryItem(
            name: "Bee-hive",
            field: [
                [.inactive, .active, .active, .inactive],
                [.active, .inactive, .inactive, .active],
                [.inactive, .active, .active, .inactive]
            ]
        )
    }
    static var loaf: LibraryItem {
        LibraryItem(
            name: "Loaf",
            field: [
                [.inactive, .active, .active, .inactive],
                [.active, .inactive, .inactive, .active],
                [.inactive, .active, .active, .inactive]
            ]
        )
    }
    static var boat: LibraryItem {
        LibraryItem(
            name: "Boat",
            field: [
                [.active, .active, .inactive],
                [.active, .inactive, .active],
                [.inactive, .active, .inactive]
            ]
        )
    }
    static var tub: LibraryItem {
        LibraryItem(
            name: "Tub",
            field: [
                [.inactive, .active, .inactive],
                [.active, .inactive, .active],
                [.inactive, .active, .inactive]
            ]
        )
    }
    static var blinker: LibraryItem {
        LibraryItem(
            name: "Blinker",
            field: [Array(repeating: .active, count: 3)]
        )
    }
    static var toad: LibraryItem {
        let row: [BinaryCell] = [.inactive, .active, .active, .active]
        return LibraryItem(
            name: "Toad",
            field: [row, row.reversed()]
        )
    }
    static var beacon: LibraryItem {
        let row: [BinaryCell] = [.active, .active, .inactive, .inactive]
        return LibraryItem(
            name: "Beacon",
            field: [row, row, row.reversed(), row.reversed()]
        )
    }
    
    static var glider: LibraryItem {
        LibraryItem(
            name: "Glider",
            field: [
                [.inactive, .active, .inactive],
                [.inactive, .inactive, .active],
                Array(repeating: .active, count: 3)
            ]
        )
    }
    
    static var bigEmpty: LibraryItem {
        LibraryItem(
            name: "BigEmpty",
            field: Array(
                repeating: Array(repeating: .inactive, count: 20),
                count: 20
            )
        )
    }
    
    static func getAllPresets() -> [LibraryItem] {
        [
            .bigEmpty, .block, .beeHive, .loaf, .boat,
            .tub, .blinker, .toad, .beacon,
            .glider
        ]
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) }
        else { self }
    }
}
