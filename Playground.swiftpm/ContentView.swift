import SwiftUI

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let emptyPager = PageViewController(pages: [])
        emptyPager.title = "Empty Pages"
        
        let seededPager = PageViewController(pages: PageViewController.seededPages())
        seededPager.title = "Seeded Pages"
        
        let emptyNav = UINavigationController(rootViewController: emptyPager)
        let seededNav = UINavigationController(rootViewController: seededPager)
        
        let vc = UITabBarController(
            tabs: [
                UITab(
                    title: "Empty",
                    image: UIImage(systemName: "square.dashed"),
                    identifier: "empty",
                    viewControllerProvider: { _ in
                        emptyNav
                    }
                ),
                UITab(
                    title: "Seeded",
                    image: UIImage(systemName: "square.stack.3d.up"),
                    identifier: "seeded",
                    viewControllerProvider: { _ in
                        seededNav
                    }
                )
            ]
        )
        if #available(iOS 26.0, *) {
            vc.tabBarMinimizeBehavior = .onScrollDown
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
