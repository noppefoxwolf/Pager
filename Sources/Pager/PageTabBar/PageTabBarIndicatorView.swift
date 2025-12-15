import UIKit

final class PageTabBarIndicatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tintColor
        if #available(iOS 26.0, *) {
            cornerConfiguration = .capsule()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if #unavailable(iOS 26.0) {
            layer.cornerRadius = bounds.height / 2
        }
    }
}
