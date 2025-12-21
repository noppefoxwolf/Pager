import UIKit

public protocol PageViewControllerDelegate: AnyObject {
    @MainActor
    func willTransition(to pendingViewControllers: [UIViewController])
    
    @MainActor
    func didFinishTransition(_ pageViewController: PageViewController)
}
