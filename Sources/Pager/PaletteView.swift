import UIKit

/// The background container used by `PaletteView`.
public final class PaletteBackgroundView: UILabel {
}

/// A vertical palette that hosts the page tab bar over its background.
public final class PaletteView: UIStackView {
    public let pageTabBar: PageTabBar

    private let backgroundView = PaletteBackgroundView()

    public init(parentViewController: UIViewController) {
        pageTabBar = PageTabBar(parentViewController: parentViewController)
        super.init(frame: .zero)
        configure()
    }

    override public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented; use init(parentViewController:)")
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        axis = .vertical

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(backgroundView, at: 0)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addArrangedSubview(pageTabBar)
    }
}
