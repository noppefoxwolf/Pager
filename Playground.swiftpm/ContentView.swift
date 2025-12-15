import SwiftUI

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        if #available(iOS 18.0, *) {
            let vc = UITabBarController(
                tabs: [
                    UITab(
                        title: "Home",
                        image: UIImage(systemName: "house"),
                        identifier: "home",
                        viewControllerProvider: { _ in
                            UINavigationController(rootViewController: PageViewController(pages: []))
                        }
                    ),
                    UITab(
                        title: "Notification",
                        image: UIImage(systemName: "bell"),
                        identifier: "notification",
                        viewControllerProvider: { _ in
                            UIHostingController(rootView: List(0..<100, rowContent: { _ in
                                Text("Hello, World!")
                            }))
                        }
                    )
                ]
            )
            if #available(iOS 26.0, *) {
                vc.tabBarMinimizeBehavior = .onScrollDown
            }
            return vc
        } else {
            return UINavigationController(
                rootViewController: PageViewController(pages: [])
            )
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

