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
        backgroundColor = .yellow
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        let leadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingConstraint.priority = .fittingSizeLevel
        let trailingConstraint = label.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingConstraint.priority = .fittingSizeLevel
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingConstraint,
            trailingConstraint,
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? LabelContentConfiguration else { return }
        var attributeContainer = AttributeContainer()
        
        let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .subheadline)
            .withSymbolicTraits(.traitBold)!
        attributeContainer.font = UIFont(descriptor: descriptor, size: 0)
        attributeContainer.foregroundColor = UIColor.label
        let transformedContainer = configuration.textProperties?.transform(attributeContainer) ?? attributeContainer
        let attributedString = AttributedString(configuration.text, attributes: transformedContainer)
        label.attributedText = NSAttributedString(attributedString)
        label.backgroundColor = .red
    }
}

