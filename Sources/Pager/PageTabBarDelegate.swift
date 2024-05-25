import Foundation

protocol PageTabBarDelegate: AnyObject {
    @MainActor
    func pageTabBar(_ pageTabBar: PageTabBar, didSelected index: Int)
}
