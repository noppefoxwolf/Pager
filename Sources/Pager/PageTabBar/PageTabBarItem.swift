import UIKit

public struct PageTab: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let viewControllerProvider: @MainActor @Sendable (PageTab) -> UIViewController
    
    public init(
        id: String,
        title: String,
        viewControllerProvider: @MainActor @Sendable @escaping (PageTab) -> UIViewController
    ) {
        self.id = id
        self.title = title
        self.viewControllerProvider = viewControllerProvider
    }
}

extension PageTab: Equatable, Hashable {
    public static func == (lhs: PageTab, rhs: PageTab) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
}
