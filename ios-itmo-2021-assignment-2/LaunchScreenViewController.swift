import Foundation
import UIKit
import SwiftUI

struct MainScreenView: UIViewControllerRepresentable {
    let isElementaryAutomataSelected: Bool?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = MainScreenViewController()
        if let isElementaryAutomataSelected = self.isElementaryAutomataSelected {
            controller.userDataManager.userDefaultsIsTwoDimentionAutomata = !isElementaryAutomataSelected
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}


class LaunchScreenViewController: UIViewController {
    private var controller: UIHostingController<LaunchScreenView>!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(named: "applicationBackgroundColor")
        self.controller = UIHostingController(rootView: LaunchScreenView())
        self.addChild(self.controller)
        self.controller.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.controller.view)
        self.controller.didMove(toParent: self)

        
        NSLayoutConstraint.activate([
            self.controller.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

struct LaunchScreenView: View {
    @State private var showingAutomataSelect = false
    @State private var showingMainScreenView = false
    @State private var isElementarySelected = false
    var body: some View {
        ZStack {
            VStack
            {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Text("Cellular Automata Simulator")
                            .font(.system(size: 30))
                        Spacer()
                    }.frame(width: geometry.size.width, height: geometry.size.height / 2, alignment: .top)
                }
            }
            VStack(spacing: 50) {
                Spacer()
                Button("Continue") {
                    self.showingMainScreenView = true
                }
                .buttonStyle(BlueButton())
                .fullScreenCover(isPresented: self.$showingMainScreenView) {
                    MainScreenView(isElementaryAutomataSelected: nil)
                }
                Button("New Field") {
                    self.showingAutomataSelect = true
                }
                .buttonStyle(BlueButton())
                .confirmationDialog("Select Automata", isPresented: self.$showingAutomataSelect) {
                    Button("Elementary") {
                        UserDefaults.standard.reset()
                        self.showingMainScreenView = true
                        self.isElementarySelected = true
                    }
                    Button("Game Of Life") {
                        UserDefaults.standard.reset()
                        self.showingMainScreenView = true
                        self.isElementarySelected = false
                    }
                }.fullScreenCover(isPresented: self.$showingMainScreenView) {
                    MainScreenView(isElementaryAutomataSelected: self.isElementarySelected)
                }
                Spacer()
            }
        }
    }
}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 200, height: 35)
            .foregroundColor(.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 6, height: 6)))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
