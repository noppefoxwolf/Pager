import SwiftUI
import Pager

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
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
        pageTabBar.dataSource = self
        
        navigationItem.title = "Pager Example"
        navigationItem.setBottomPalette(pageTabBar)
        
        reloadData()
    }
    
    var items = [
        "Following",
        "Local",
        "Global",
        "#ios_developers",
    ]
    
    func barItem(for bar: PageTabBar, at index: Int) -> any PageTabBarItem {
        DefaultPageTabBarItem(title: items[index])
    }
    
    func numberOfViewControllers(in pageViewController: Pager.PageViewController) -> Int {
        items.count
    }
    
    func viewController(for pageViewController: Pager.PageViewController, at index: Int) -> UIViewController? {
        UIHostingController(rootView: Text(items[index]))
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
