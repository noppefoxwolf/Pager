import UIKit

@MainActor
public final class Page: Identifiable {
    public let id: String
    public let title: String
    public let viewControllerProvider: @MainActor @Sendable (Page) -> UIViewController
    
    private var _viewController: UIViewController? = nil
    
    @MainActor
    public var viewController: UIViewController {
        if let _viewController {
            return _viewController
        }
        let newViewController = viewControllerProvider(self)
        _viewController = newViewController
        return newViewController
    }
    
    public init(
        id: String,
        title: String,
        viewControllerProvider: @MainActor @Sendable @escaping (Page) -> UIViewController
    ) {
        self.id = id
        self.title = title
        self.viewControllerProvider = viewControllerProvider
    }
}
