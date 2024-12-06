import UIKit
import CollectionViewDistributionalLayout
import LabelContentConfiguration
import os

public final class PageTabBar: UICollectionView {
    let indicatorView = PageTabBarIndicatorView()
    weak var tabBarDelegate: (any PageTabBarDelegate)? = nil
    public weak var tabBarDataSource: (any PageTabBarDataSource)? = nil
    let feedbackGenerator = FeedbackGenerator()
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    public init() {
        super.init(frame: .null, collectionViewLayout: CollectionViewDistributionalLayout())
        backgroundColor = .clear
        delegate = self
        dataSource = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        
        feedbackGenerator.prepare()
        
        addSubview(indicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, PageTabBarItem>(
        handler: { cell, indexPath, item in
            var contentConfiguration = cell.labelConfiguration()
            contentConfiguration.text = item.title
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
        let item = tabBarDataSource?.pageTabBar(self, controlForItemAt: indexPath.row)
        guard let item else { fatalError() }
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item
        )
    }
    
    func setIndicator(_ position: Double, columnCount: Int) {
        let fixedPosition = position * Double(columnCount)
        let leftItemIndex = Int(floor(fixedPosition))
        let rightItemIndex = leftItemIndex + (columnCount - 1)
        let fractionCompleted = fixedPosition - floor(fixedPosition)
        
        let minX = minX(index: leftItemIndex, fractionCompleted: fractionCompleted) ?? 0
        let maxX = maxX(index: rightItemIndex, fractionCompleted: fractionCompleted) ?? maxX(index: leftItemIndex, fractionCompleted: fractionCompleted)
        
        indicatorView.frame.size.width = (maxX ?? minX) - minX
        indicatorView.frame.size.height = 4
        indicatorView.frame.origin.x = minX
        indicatorView.frame.origin.y = bounds.height - 4
    }
    
    func minX(index: Int, fractionCompleted: Double) -> CGFloat? {
        guard let minX = self.frame(at: index)?.minX else { return nil }
        let nextMinX = self.frame(at: index + 1)?.minX ?? minX
        return minX + ((nextMinX - minX) * fractionCompleted)
    }
    
    func maxX(index: Int, fractionCompleted: Double) -> CGFloat? {
        guard let maxX = self.frame(at: index)?.maxX else { return nil }
        let nextMaxX = self.frame(at: index + 1)?.maxX ?? maxX
        return maxX + ((nextMaxX - maxX) * fractionCompleted)
    }
    
    
//        let section = 0
//        let fixedPosition = position * Double(columnCount)
//        
//        let leftItemIndex = Int(floor(fixedPosition))
//        let rightItemIndex = Int(floor(fixedPosition)) + (columnCount - 1)//Int(ceil(fixedPosition)) + (columnCount - 1)
//        let fractionCompleted = fixedPosition - floor(fixedPosition)
//        
////        logger.debug("position: \(fixedPosition)")
//        logger.debug("left: \(leftItemIndex), right: \(rightItemIndex), fraction: \(fractionCompleted)")
//        
//        let focusIndex = Int(fixedPosition.rounded())
//        let indexPath = IndexPath(row: focusIndex, section: section)
//        
//        if rowSequence(for: section).contains(focusIndex) {
//            if let indexPathsForSelectedItems, !indexPathsForSelectedItems.isEmpty, !indexPathsForSelectedItems.contains(indexPath) {
//                feedbackGenerator.selectionChanged()
//            }
//            selectItem(
//                at: indexPath,
//                animated: true,
//                scrollPosition: .centeredHorizontally
//            )
//        }
//        
//        guard let leftItemCell = cellForItem(at: IndexPath(row: leftItemIndex, section: section)) else { return }
//        let rightItemCell = cellForItem(at: IndexPath(row: rightItemIndex, section: section))
//        guard let leftItemLabel = leftItemCell.contentView.subviews.first(where: { $0 is UILabel }) else { return }
//        let rightItemLabel = rightItemCell?.contentView.subviews.first(where: { $0 is UILabel })
//
//        let minX = leftItemLabel.convert(leftItemLabel.bounds, to: self).minX
//        let maxX = (rightItemLabel ?? leftItemLabel).convert((rightItemLabel ?? leftItemLabel).bounds, to: self).maxX
//    }
    
    func frame(at index: Int) -> CGRect? {
        let indexPath = IndexPath(row: index, section: 0)
        let cell = cellForItem(at: indexPath)
        let label = cell?.contentView.subviews.first(where: { $0 is UILabel })
        guard let label else { return nil }
        return label.convert(label.bounds, to: self)
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

extension UICollectionView {
    package func rowSequence(for section: Int) -> some Sequence<Int> {
        let numberOfRows = numberOfItems(inSection: section)
        return (0..<numberOfRows)
    }
}
