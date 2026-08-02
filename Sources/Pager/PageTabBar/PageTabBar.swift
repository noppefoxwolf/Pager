import SwiftUI
import UIKit

/// UIKit content view that hosts the SwiftUI page tab bar.
@MainActor
public final class PageTabBar: UIView, UIContentView {
    public var configuration: UIContentConfiguration

    private let hostingController: UIViewController

    public init(state: PageTabBarState) {
        self.configuration = PageTabBarContentConfiguration(state: state)
        let hostingController = UIHostingController(
            rootView: PageTabBarView().environment(state)
        )
        hostingController.safeAreaRegions = []
        self.hostingController = hostingController
        super.init(frame: .zero)

        backgroundColor = .clear
        hostingController.view.layoutMargins = .zero
        hostingController.view.preservesSuperviewLayoutMargins = false
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 34)
    }
}

private struct PageTabBarContentConfiguration: UIContentConfiguration {
    let state: PageTabBarState

    func makeContentView() -> UIView & UIContentView {
        PageTabBar(state: state)
    }

    func updated(for state: UIConfigurationState) -> PageTabBarContentConfiguration {
        self
    }
}
