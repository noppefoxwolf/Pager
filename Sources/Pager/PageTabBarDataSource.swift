import Foundation

public protocol PageTabBarDataSource: AnyObject {
    @MainActor
    func numberOfItems(in bar: PageTabBar) -> Int
    
    @MainActor
    func pageTabBar(_ bar: PageTabBar, controlForItemAt index: Int) -> any PageTabBarItem
}
