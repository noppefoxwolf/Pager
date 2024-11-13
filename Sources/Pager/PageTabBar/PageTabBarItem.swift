import UIKit

public protocol PageTabBarItem {
    var title: String { get }
}

public struct DefaultPageTabBarItem: PageTabBarItem {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}
