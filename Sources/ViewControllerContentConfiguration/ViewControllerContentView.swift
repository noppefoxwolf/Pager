import UIKit

final class ViewControllerContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            onConfigurationChanged(
                oldValue: oldValue,
                newValue: configuration
            )
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

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        ownConfiguration.viewController.viewIfLoaded?.setNeedsLayout()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            ownConfiguration.viewController.willMove(toParent: ownConfiguration.parent)
        } else {
            ownConfiguration.viewController.willMove(toParent: nil)
        }
    }

    func onConfigurationChanged(
        oldValue configuration: UIContentConfiguration,
        newValue newConfiguration: UIContentConfiguration
    ) {
        if let configuration = configuration as? ViewControllerContentConfiguration {
            configuration.viewController.willMove(toParent: nil)
            configuration.viewController.viewIfLoaded?.removeFromSuperview()
            configuration.viewController.removeFromParent()
        }

        if let configuration = newConfiguration as? ViewControllerContentConfiguration {
            configuration.parent?.addChild(configuration.viewController)
            configuration.viewController.loadViewIfNeeded()

            let contentView = configuration.viewController.viewIfLoaded!
            contentView.translatesAutoresizingMaskIntoConstraints = false

            addSubview(contentView)
            NSLayoutConstraint.activate(
                [
                    contentView.topAnchor.constraint(
                        equalTo: topAnchor
                    ),
                    bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    contentView.leadingAnchor.constraint(
                        equalTo: leadingAnchor
                    ),
                    trailingAnchor.constraint(
                        equalTo: contentView.trailingAnchor
                    ),
                ]
            )
            configuration.viewController.didMove(toParent: configuration.parent)
        }
    }
}
