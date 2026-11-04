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

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        install(ownConfiguration)
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
            install(configuration)
        }
    }

    private func install(_ configuration: ViewControllerContentConfiguration) {
        guard superview != nil else { return }

        if let parent = configuration.parent,
           configuration.viewController.parent !== parent {
            parent.addChild(configuration.viewController)
        }

        configuration.viewController.loadViewIfNeeded()
        guard let contentView = configuration.viewController.viewIfLoaded else { return }
        guard contentView.superview !== self else { return }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate(
            [
                contentView.topAnchor.constraint(equalTo: topAnchor),
                bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ]
        )
        configuration.viewController.didMove(toParent: configuration.parent)
    }
}
