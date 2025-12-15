import UIKit

package struct ViewControllerContentConfiguration: UIContentConfiguration {
    weak var parent: UIViewController? = nil
    package var viewController: UIViewController
    
    package init(viewController: UIViewController, parent: UIViewController?) {
        self.parent = parent
        self.viewController = viewController
    }
    
    package func makeContentView() -> UIView & UIContentView {
        ViewControllerContentView(self)
    }
    
    package func updated(for state: UIConfigurationState) -> ViewControllerContentConfiguration {
        self
    }
}
