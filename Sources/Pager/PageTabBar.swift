import UIKit

public final class PageTabBar: UIStackView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        spacing = UIStackView.spacingUseSystem
        addSubview(indicatorView)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public weak var tabBarDataSource: (any PageTabBarDataSource)? = nil
    weak var delegate: (any PageTabBarDelegate)? = nil
    
    let indicatorView = PageTabBarIndicatorView()
    
    func reloadData(_ count: Int) {
        arrangedSubviews.forEach({
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        for i in 0..<count {
            if let barItem = tabBarDataSource?.pageTabBar(self, controlForItemAt: i) {
                let button = barItem.makeButton()
                button.addAction(
                    UIAction { [unowned self, i] _ in
                        delegate?.pageTabBar(self, didSelected: i)
                    },
                    for: .primaryActionTriggered
                )
                addArrangedSubview(button)
            }
        }
        if count > 3 {
            distribution = .fillProportionally
        } else {
            distribution = .fillEqually
        }
    }
    
    var previousPosition: Double = 0
    func setIndicator(_ position: Double) {
        previousPosition = position
        
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // On change SplitView width.
        setIndicator(previousPosition)
    }
}
