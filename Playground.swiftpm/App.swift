import SwiftUI
import Pager

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea()
        }
    }
}

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        UINavigationController(rootViewController: PageViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

final class PageViewController: Pager.PageViewController, Pager.PageTabBarDataSource, Pager.PageViewControllerDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        pageTabBar.tabBarDataSource = self
        
        navigationItem.title = "Pager Example"
        pageTabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 34)
        navigationItem.setBottomPalette(pageTabBar)
        
        let decrementButton = UIBarButtonItem(
            image: UIImage(systemName: "minus"),
            primaryAction: UIAction { [unowned self] _ in
                if !items.isEmpty {
                    items.removeLast()
                }
                self.reloadData()
            }
        )
        let incrementButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            primaryAction: UIAction { [unowned self] _ in
                // random length words
                let phrases: [String] = [
                    "Pager",
                    "SwiftUI",
                    "SwiftUI Pager",
                    "SwiftUI Pager Example",
                ]
                items.append(phrases.randomElement()!)
                self.reloadData()
            }
        )
        
        navigationItem.rightBarButtonItems = [
            incrementButton,
            decrementButton,
        ]
        
        reloadData()
    }
    
    var items: [String] = []
    
    func numberOfItems(in bar: PageTabBar) -> Int {
        items.count
    }
    
    func pageTabBar(_ bar: PageTabBar, controlForItemAt index: Int) -> String {
        //DefaultPageTabBarItem(title: items[index]).makeButton()
        items[index]
    }
    
    func numberOfViewControllers(
        in pageViewController: Pager.PageViewController
    ) -> Int {
        items.count
    }
    
    func viewController(
        for pageViewController: Pager.PageViewController,
        at index: Int
    ) -> UIViewController? {
        if items.indices.contains(index) {
            ChildViewController(text: items[index])
        } else {
            nil
        }
    }
}

import UIKit

extension UINavigationItem {
    // https://twitter.com/sebjvidal/status/1748659522455937213?s=61&t=QkfPitI5Z7OEKMAvToTbCA
    public func setBottomPalette(_ contentView: UIView) {
        let _UINavigationBarPalette = NSClassFromString("_UINavigationBarPalette") as! UIView.Type
        let palette = _UINavigationBarPalette.perform(NSSelectorFromString("alloc"))
            .takeUnretainedValue()
            .perform(Selector(("initWithContentView:")), with: contentView)
            .takeUnretainedValue()

        let _setButtomPaletteSelector = Selector(("_setBottomPalette:"))
        if responds(to: _setButtomPaletteSelector) {
            perform(_setButtomPaletteSelector, with: palette)
        }
    }
}


class ChildViewController: UIViewController {
    let label: UILabel = UILabel()
    let button: UIButton = UIButton(configuration: .filled())
    let text: String
    
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        label.text = text
        button.configuration?.title = "Button"
        
        let stackView = UIStackView(
            arrangedSubviews: [
                label,
                button
            ]
        )
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            view.trailingAnchor.constraint(
                equalTo: stackView.safeAreaLayoutGuide.trailingAnchor,
                constant: 20
            ),
        ])
    }
}
