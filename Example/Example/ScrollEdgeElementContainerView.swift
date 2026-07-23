import UIKit

@available(iOS 26.0, *)
final class ScrollEdgeElementContainerView<View: UIView>: UILabel {
    init(content: View) {
        super.init(frame: .zero)
        
        textColor = .clear
        isUserInteractionEnabled = true
        
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: content.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: content.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
