import UIKit

public final class Page: Identifiable {
    public let id: String
    public let title: String
    public let viewControllerProvider: @MainActor @Sendable (Page) -> UIViewController
    
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

extension Page: Equatable, Hashable {
    public static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
}
