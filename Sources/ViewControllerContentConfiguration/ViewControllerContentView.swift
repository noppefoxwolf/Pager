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

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            uninstall(ownConfiguration)
        } else {
            install(ownConfiguration)
        }
    }

    func onConfigurationChanged(
        oldValue configuration: UIContentConfiguration,
        newValue newConfiguration: UIContentConfiguration
    ) {
        if let configuration = configuration as? ViewControllerContentConfiguration {
            uninstall(configuration)
        }
        if let configuration = newConfiguration as? ViewControllerContentConfiguration {
            install(configuration)
        }
    }

    private func install(_ configuration: ViewControllerContentConfiguration) {
        guard window != nil, let parent = configuration.parent else { return }
        let controller = configuration.viewController
        guard controller.parent == nil else { return }

        parent.addChild(controller)
        controller.loadViewIfNeeded()
        guard let contentView = controller.viewIfLoaded else { return }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        controller.didMove(toParent: parent)
    }

    private func uninstall(_ configuration: ViewControllerContentConfiguration) {
        let controller = configuration.viewController
        guard controller.parent != nil else { return }
        controller.willMove(toParent: nil)
        controller.viewIfLoaded?.removeFromSuperview()
        controller.removeFromParent()
    }
}
