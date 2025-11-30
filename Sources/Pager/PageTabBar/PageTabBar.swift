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
        super.init(frame: .null, collectionViewLayout: .distributional())
        backgroundColor = .clear
        delegate = self
        dataSource = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        
        feedbackGenerator.prepare()
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = true
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
    
    func setIndicator(_ position: Double) {
        updateSelectedTabItem(for: position)
        updateIndicatorFrame(for: position)
    }
    
    private func updateSelectedTabItem(for position: Double) {
        let section = 0
        let focusIndex = Int(position.rounded())
        let indexPath = IndexPath(row: focusIndex, section: section)
        
        guard rowSequence(for: section).contains(focusIndex) else { return }
        
        // Trigger haptic feedback when selection changes
        let selectedItems = indexPathsForSelectedItems ?? []
        
        print(position)
        if position.truncatingRemainder(dividingBy: 1) == 0 {
            feedbackGenerator.selectionChanged()
            selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
    
    private func updateIndicatorFrame(for position: Double) {
        let section = 0
        let prevIndex = Int(floor(position))
        let nextIndex = Int(ceil(position))
        let progress = position - floor(position)
        
        guard let prevCell = cellForItem(at: IndexPath(row: prevIndex, section: section)),
              let prevLabel = prevCell.contentView.subviews.first(where: { $0 is UILabel }) as? UILabel else {
            return
        }
        
        let nextCell = cellForItem(at: IndexPath(row: nextIndex, section: section)) ?? prevCell
        let nextLabel = nextCell.contentView.subviews.first(where: { $0 is UILabel }) as? UILabel ?? prevLabel
        
        // Calculate interpolated width and position
        let startWidth = prevLabel.bounds.width
        let endWidth = nextLabel.bounds.width
        let interpolatedWidth = startWidth + (endWidth - startWidth) * progress
        
        let startCenterX = prevCell.center.x
        let endCenterX = nextCell.center.x
        let interpolatedCenterX = startCenterX + (endCenterX - startCenterX) * progress
        
        // Update indicator frame
        indicatorView.frame.size = CGSize(width: interpolatedWidth, height: 4)
        indicatorView.frame.origin.y = bounds.height - 4
        indicatorView.center.x = interpolatedCenterX
    }
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
}

extension PageTabBar: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        // この時点でselectedIndexに入るが、スクロール位置が前のままなので2回changedが呼ばれてしまう
        // deselectしても前回の値が消えるので意味がない
        tabBarDelegate?.pageTabBar(self, didSelected: indexPath.row)
    }
}

extension UICollectionView {
    package func rowSequence(for section: Int) -> some Sequence<Int> {
        let numberOfRows = numberOfItems(inSection: section)
        return (0..<numberOfRows)
    }
}
