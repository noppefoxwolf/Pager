import UIKit

extension UICollectionViewCell {
    package func viewControllerConfiguration(
        viewController: UIViewController,
        parent: UIViewController?
    ) -> ViewControllerContentConfiguration {
        ViewControllerContentConfiguration(viewController: viewController, parent: parent)
    }
}
