import UIKit

public protocol PageViewControllerDataSource: AnyObject {
    @MainActor
    func numberOfViewControllers(
        in pageViewController: PageViewController
    ) -> Int

    @MainActor
    func viewController(
        for pageViewController: PageViewController,
        at index: Int
    ) -> UIViewController?
}
