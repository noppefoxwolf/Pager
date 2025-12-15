import UIKit

final class ViewControllerContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    
    var ownConfiguration: ViewControllerContentConfiguration {
        configuration as! ViewControllerContentConfiguration
    }

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview {
            ownConfiguration.viewController.didMove(toParent: ownConfiguration.parent)
        } else {
            ownConfiguration.viewController.didMove(toParent: nil)
        }
    }

    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? ViewControllerContentConfiguration else { return }
        configuration.viewController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(configuration.viewController.view)
        NSLayoutConstraint.activate(
            [
                configuration.viewController.view.topAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.topAnchor
                ),
                safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: configuration.viewController.view.bottomAnchor),
                configuration.viewController.view.leadingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.leadingAnchor
                ),
                safeAreaLayoutGuide.trailingAnchor.constraint(
                    equalTo: configuration.viewController.view.trailingAnchor
                ),
            ]
        )
    }
}

