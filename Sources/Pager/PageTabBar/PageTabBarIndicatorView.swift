import UIKit

final class PageTabBarIndicatorView: UIView {
    let mainIndicatorView = IndicatorView()
    let subIndicatorView = IndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainIndicatorView.backgroundColor = .tintColor
        subIndicatorView.backgroundColor = .tintColor.withAlphaComponent(0.5)
        addSubview(mainIndicatorView)
        addSubview(subIndicatorView)
        
        mainIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: mainIndicatorView.bottomAnchor),
            mainIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            trailingAnchor.constraint(equalTo: mainIndicatorView.trailingAnchor),
            mainIndicatorView.widthAnchor.constraint(equalTo: subIndicatorView.widthAnchor, multiplier: 0.5)
        ])
        
        subIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: subIndicatorView.bottomAnchor),
            subIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: subIndicatorView.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

final class IndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
