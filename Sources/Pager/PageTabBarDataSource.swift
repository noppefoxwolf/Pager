import Foundation

public protocol PageTabBarDataSource: AnyObject {
    @MainActor
    func barItem(for bar: PageTabBar, at index: Int) -> any PageTabBarItem
}
