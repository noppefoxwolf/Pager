import SwiftUI
import UIKit

/// UIKit content view that hosts the SwiftUI page tab bar.
@MainActor
public final class PageTabBar: UIView, UIContentView {
    public var configuration: UIContentConfiguration

    private let hostedContentView: UIView & UIContentView

    public init(state: PageTabBarState) {
        self.hostedContentView = UIHostingConfiguration {
            PageTabBarView()
                .environment(state)
        }
        .makeContentView()
        self.configuration = hostedContentView.configuration
        super.init(frame: .zero)

        backgroundColor = .clear
        hostedContentView.layoutMargins = .zero
        hostedContentView.preservesSuperviewLayoutMargins = false
        hostedContentView.backgroundColor = .clear
        hostedContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostedContentView)
        NSLayoutConstraint.activate([
            hostedContentView.topAnchor.constraint(equalTo: topAnchor),
            hostedContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostedContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostedContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 34)
    }
}
