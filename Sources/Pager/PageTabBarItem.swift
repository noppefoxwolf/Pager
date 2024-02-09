import UIKit

public protocol PageTabBarItem {
    @MainActor
    func makeButton() -> UIButton
}

public struct DefaultPageTabBarItem: PageTabBarItem {
    let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public func makeButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.setTitleColor(.label, for: .normal)
        button.setTitle(title, for: .normal)
        return button
    }
}
