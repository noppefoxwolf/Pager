import UIKit

@MainActor
public protocol PageTabBarDataSource: AnyObject {
    func numberOfItems(in bar: PageTabBar) -> Int
    func pageTabBar(_ bar: PageTabBar, controlForItemAt index: Int) -> UIControl
}
