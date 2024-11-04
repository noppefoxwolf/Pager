import UIKit
import ProportionalLayout
import LabelContentConfiguration
import os

public final class PageTabBar: UICollectionView {
    let indicatorView = PageTabBarIndicatorView()
    weak var tabBarDelegate: (any PageTabBarDelegate)? = nil
    public weak var tabBarDataSource: (any PageTabBarDataSource)? = nil
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    public init() {
        super.init(frame: .null, collectionViewLayout: ProportionalCollectionViewLayout())
        delegate = self
        dataSource = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        addSubview(indicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, String>(
        handler: { cell, indexPath, text in
            var contentConfiguration = cell.labelConfiguration()
            contentConfiguration.text = text
            contentConfiguration.textProperties = .init({ [weak cell] attributeContainer in
                var attributeContainer = attributeContainer
                if cell?.configurationState.isSelected == true {
                    attributeContainer.foregroundColor = UIColor.label
                } else {
                    attributeContainer.foregroundColor = UIColor.placeholderText
                }
                return attributeContainer
            })
            cell.contentConfiguration = contentConfiguration
        }
    )
}

extension PageTabBar: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        tabBarDataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let item = tabBarDataSource?.pageTabBar(self, controlForItemAt: indexPath.row) ?? ""
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item
        )
    }
    
    func setIndicator(_ position: Double) {
        logger.debug("setIndicator: \(position)")
        let section = 0
        
        let prevIndex = Int(floor(position))
        let currentIndex = Int(ceil(position))
        let fractionCompleted = position - floor(position)
        
        let focusIndex = Int(position.rounded())
        if rowSequence(for: section).contains(focusIndex) {
            let indexPath = IndexPath(row: focusIndex, section: section)
            selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        
        let prevCell = cellForItem(at: IndexPath(row: prevIndex, section: section))
        let currentCell = cellForItem(at: IndexPath(row: currentIndex, section: section))
        let prevLabel = prevCell?.contentView.subviews.first(where: { $0 is UILabel })
        let currentLabel = currentCell?.contentView.subviews.first(where: { $0 is UILabel })

        let prevWidth = prevLabel?.bounds.width ?? 0
        let prevCenter = prevCell?.center ?? .zero
        let currentWidth = currentLabel?.bounds.width ?? 0
        let currentCenter = currentCell?.center ?? .zero
        logger.debug("prevWidth: \(prevWidth) currentWidth: \(currentWidth)")

        indicatorView.frame.size.width =
        prevWidth + ((currentWidth - prevWidth) * fractionCompleted)
        indicatorView.frame.size.height = 4
        indicatorView.frame.origin.y = bounds.height - 4

        indicatorView.center.x =
        prevCenter.x + ((currentCenter.x - prevCenter.x) * fractionCompleted)
    }
}

extension PageTabBar: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        tabBarDelegate?.pageTabBar(self, didSelected: indexPath.row)
    }
}

