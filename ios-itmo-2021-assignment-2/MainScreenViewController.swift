import UIKit
import CellularAutomataSimulator
import DeveloperToolsSupport

enum ApplicationMode {
    case play
    case pause
    case edit
    case library
}

enum PlaySpeed {
    case fast
    case normal
    case slow
}

class MainScreenViewSettings {
    var mode: ApplicationMode
    var currentStateTitle: String
    var currentPlaySpeed: PlaySpeed
    
    init() {
        self.mode = .pause
        self.currentPlaySpeed = .normal
        self.currentStateTitle = "Empty Field"
    }
}

class MainScreenViewController: UIViewController {
    var appSettings: AppSettings
    let userDataManager: UserDataManager
    var controllerSettings: MainScreenViewSettings
    var twoDimentionAutomata: TwoDimentionCelluralAutomata
    var elementaryAutomata: ElementaryCelluralAutomata
    var celluralAutomataUIView: CelluralAutomataUIView!
    var scrollView: UIScrollView!
    var toolbar: UIToolbar!
    var navbar: UINavigationBar!
    var playButtonTimer: Timer!
    var automataSnapshotLibrary: SnapshotLibraryViewController!
    var automataStateLibrary: AutomataLibraryViewController!
    
    var selectFieldView: UISelectFieldView!
    
    init() {
        self.appSettings = AppSettings()
        self.userDataManager = UserDataManager()
        self.controllerSettings = MainScreenViewSettings()
        self.twoDimentionAutomata = TwoDimentionCelluralAutomata()
        self.elementaryAutomata = ElementaryCelluralAutomata(
            ruleCode: self.userDataManager.userDefaultsElementaryAutomataCode
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.switchToCurrentThemeMode()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "applicationBackgroundColor")
        self.setupScrollView()
        self.setupCelluralAutomataUIView()
        self.selectFieldView = UISelectFieldView(
            selectBlockSideSize: self.celluralAutomataUIView.sideLength
        )
        self.selectFieldView.backgroundColor = UIColor(named: "selectFieldColor")?.withAlphaComponent(0.5)
        self.selectFieldView.layer.borderColor = UIColor(named: "selectFieldColor")?.resolvedColor(with: self.traitCollection).cgColor
        self.selectFieldView.isHidden = true
        self.celluralAutomataUIView.addSubview(self.selectFieldView)
        self.setupNavbar()
        self.setupToolbar()
        self.setUIInCurrentMode()
        self.setupStateLibrary()
        self.switchToCurrentThemeMode()
        NSLayoutConstraint.activate([
            self.navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.toolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.navbar.bottomAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.toolbar.topAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        ])
    }
    func redrawCelluralAutomataUIView() {
        self.scrollView.contentSize = self.celluralAutomataUIView.frame.size
        self.celluralAutomataUIView.setNeedsDisplay()
    }
    func setUIInCurrentMode() {
        self.setNavbarInCurrentMode()
        self.setToolbarInCurrentMode()
    }
    @objc func celluralAutomataUIViewTap(_ sender: UITapGestureRecognizer) {
        if self.controllerSettings.mode == .pause {
            let point = sender.location(in: self.celluralAutomataUIView)
            self.celluralAutomataUIView.changeCellValue(point: point)
            self.celluralAutomataUIView.setNeedsDisplay()
        }
    }
    func setupScrollView() {
        self.scrollView = UIScrollView()
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.maximumZoomScale = 3
        self.scrollView.minimumZoomScale = 0.2
        self.scrollView.zoomScale = 1.0
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
    }
    func setupCelluralAutomataUIView() {
        self.celluralAutomataUIView = CelluralAutomataUIView()
        self.celluralAutomataUIView.size = Size(
            width: 20, height: 20
        )
        self.celluralAutomataUIView.cellMode = self.userDataManager.userDefaultsFieldCellType
        self.celluralAutomataUIView.backgroundColor = self.view.backgroundColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.celluralAutomataUIViewTap))
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.celluralAutomataUIViewLongPress)
        )
        self.celluralAutomataUIView.addGestureRecognizer(tapGesture)
        self.celluralAutomataUIView.addGestureRecognizer(longPressGesture)
        self.scrollView.contentSize = self.celluralAutomataUIView.frame.size
        self.scrollView.addSubview(self.celluralAutomataUIView)
    }
    func setupNavbar() {
        self.navbar = UINavigationBar(frame: CGRect.zero)
        self.navbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.navbar)
    }
    func setupToolbar() {
        self.toolbar = UIToolbar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 44)
        )
        self.toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.toolbar)
    }
    func setupStateLibrary() {
        self.automataStateLibrary = AutomataLibraryViewController(
            title: "Library",
            automataField: self.celluralAutomataUIView,
            fieldPasteboard: self.appSettings.fieldPasteboard,
            userDataManager: self.userDataManager
        )
        self.automataSnapshotLibrary = SnapshotLibraryViewController(
            title: "Snapshots",
            automataField: self.celluralAutomataUIView,
            fieldPasteboard: self.appSettings.fieldPasteboard,
            userDataManager: self.userDataManager
        )
    }
    func copyFieldToClipboard(field: [[BinaryCell]]) {
        self.appSettings.fieldPasteboard.strings = field.map { row in
            row.map { cell in
                cell == .active ? "1" : "0"
            }.joined()
        }
    }
    func readFieldFromClipboard() -> [[BinaryCell]] {
        if let data = self.appSettings.fieldPasteboard.strings {
            return data.map { str in
                Array(str).map { cellStr in
                    cellStr == "1" ? .active : .inactive
                }
            }
        }
        return []
    }
}



extension MainScreenViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.celluralAutomataUIView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let zoomScale = scrollView.zoomScale
        self.selectFieldView.bounds = CGRect(
            origin: CGPoint.zero,
            size: CGSize(
                width: self.selectFieldView.frame.width * zoomScale,
                height: self.selectFieldView.frame.height * zoomScale
            )
        )
        
        self.selectFieldView.transform = CGAffineTransform(
            scaleX: 1.0 / scrollView.zoomScale,
            y: 1.0 / scrollView.zoomScale
        )
    }
}
