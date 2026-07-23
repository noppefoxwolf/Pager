import UIKit

@available(iOS 26.0, *)
final class ScrollEdgeElementContainerView<View: UIView>: UILabel {
    let content: View
    
    init(content: View) {
        self.content = content
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
    
    override var intrinsicContentSize: CGSize {
        content.intrinsicContentSize
    }
}
