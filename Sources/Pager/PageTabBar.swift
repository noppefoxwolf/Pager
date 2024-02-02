import UIKit

public final class PageTabBar: UIStackView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal

        addSubview(indicatorView)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public weak var dataSource: (any PageTabBarDataSource)? = nil
    weak var delegate: (any PageTabBarDelegate)? = nil

    let indicatorView = PageTabBarIndicatorView()

    func reloadData(_ count: Int) {
        arrangedSubviews.forEach({
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        for i in 0..<count {
            let button = UIButton(type: .custom)
            button.addAction(
                UIAction { [unowned self, i] _ in
                    delegate?.pageTabBar(self, didSelected: i)
                },
                for: .primaryActionTriggered
            )
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.minimumScaleFactor = 0.25
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.setTitleColor(.label, for: .normal)
            let barItem = dataSource?.barItem(for: self, at: i)
            button.setTitle(barItem, for: .normal)
            addArrangedSubview(button)
        }
        if count > 3 {
            distribution = .fillProportionally
        } else {
            distribution = .fillEqually
        }
    }

    func setIndicator(_ position: Double) {
        let prevIndex = Int(floor(position))
        let currentIndex = Int(ceil(position))
        let fractionCompleted = position - floor(position)

        let focusIndex = Int(position.rounded())
        arrangedSubviews
            .compactMap({ $0 as? UIButton })
            .enumerated()
            .forEach { (index, button) in
                let color: UIColor = index == focusIndex ? .label : .placeholderText
                button.setTitleColor(color, for: .normal)
            }

        let prevButton = button(at: prevIndex)
        let currentButton = button(at: currentIndex)

        let prevWidth = max(prevButton?.titleLabel?.bounds.width ?? 0, 44)
        let prevCenter = prevButton?.center ?? .zero
        let currentWidth = max(currentButton?.titleLabel?.bounds.width ?? 0, 44)
        let currentCenter = currentButton?.center ?? .zero

        indicatorView.frame.size.width =
            prevWidth + ((currentWidth - prevWidth) * fractionCompleted)
        indicatorView.frame.size.height = 4
        indicatorView.frame.origin.y = bounds.height - 4

        indicatorView.center.x =
            prevCenter.x + ((currentCenter.x - prevCenter.x) * fractionCompleted)
    }

    func button(at index: Int) -> UIButton? {
        guard arrangedSubviews.indices.contains(index) else { return nil }
        return (arrangedSubviews[index] as? UIButton)
    }
}
