import UIKit

final class LabelContentView: UIView, UIContentView {
    private let label = UILabel()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        let leadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingConstraint.priority = .defaultLow
        let trailingConstraint = label.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingConstraint,
            trailingConstraint,
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? LabelContentConfiguration else { return }
        var attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont.preferredFont(forTextStyle: .body)
        attributeContainer.foregroundColor = UIColor.label
        let transformedContainer = configuration.textProperties?.transform(attributeContainer) ?? attributeContainer
        var attributedString = AttributedString(configuration.text, attributes: transformedContainer)
        label.attributedText = NSAttributedString(attributedString)
    }
}

