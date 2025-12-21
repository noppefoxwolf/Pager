import UIKit
import CollectionViewDistributionalLayout
import LabelContentConfiguration
import os

public final class PageTabBar: UICollectionView {
    let indicatorView = PageTabBarIndicatorView()
    weak var tabBarDelegate: (any PageTabBarDelegate)? = nil
    lazy var tabBarDataSource = UICollectionViewDiffableDataSource<Section, Page.ID>(
        collectionView: self,
        cellProvider: { [unowned self] collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistration,
                for: indexPath,
                item: item
            )
        }
    )
    let feedbackGenerator = FeedbackGenerator()
    var pagesByID: [Page.ID: Page] = [:]
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    public init() {
        super.init(frame: .zero, collectionViewLayout: .distributional())
        _ = cellRegistration
        backgroundColor = .clear
        delegate = self
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
    
    lazy var cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Page.ID>(
        handler: { [weak self] cell, _, item in
            guard let page = self?.pagesByID[item] else {
                cell.contentConfiguration = nil
                return
            }
            var contentConfiguration = cell.labelConfiguration()
            contentConfiguration.text = page.title
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
        if !selectedItems.contains(indexPath) {
            feedbackGenerator.selectionChanged()
            selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    private func updateIndicatorFrame(for position: Double) {
        let section = 0
        let prevIndex = Int(floor(position))
        let nextIndex = Int(ceil(position))
        let progress = position - floor(position)

        guard let prevAttributes = layoutAttributesForItem(
            at: IndexPath(row: prevIndex, section: section)
        ) else {
            return
        }

        let nextAttributes = layoutAttributesForItem(
            at: IndexPath(row: nextIndex, section: section)
        ) ?? prevAttributes
        
        // Prefer actual label frames (reflect font / content changes), fall back to layout attributes
        let startFrame = labelFrame(at: prevIndex) ?? CGRect(
            x: prevAttributes.center.x - prevAttributes.size.width / 2,
            y: prevAttributes.frame.minY,
            width: prevAttributes.size.width,
            height: prevAttributes.size.height
        )
        let endFrame = labelFrame(at: nextIndex) ?? CGRect(
            x: nextAttributes.center.x - nextAttributes.size.width / 2,
            y: nextAttributes.frame.minY,
            width: nextAttributes.size.width,
            height: nextAttributes.size.height
        )
        
        let startWidth = startFrame.width
        let endWidth = endFrame.width
        let interpolatedWidth = startWidth + (endWidth - startWidth) * progress
        
        let startCenterX = startFrame.midX
        let endCenterX = endFrame.midX
        let interpolatedCenterX = startCenterX + (endCenterX - startCenterX) * progress
        
        // Update indicator frame
        indicatorView.frame.size = CGSize(width: interpolatedWidth, height: 4)
        indicatorView.frame.origin.y = bounds.height - 4
        indicatorView.center.x = interpolatedCenterX
    }
    
    /// 現在描画されているセルからラベルのフレームを取り出し、`PageTabBar` 座標系に変換して返す
    private func labelFrame(at index: Int) -> CGRect? {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = cellForItem(at: indexPath) else { return nil }
        let label = (cell.contentView as? LabelContentView)?.label
        guard let label else { return nil }
        return label.convert(label.bounds, to: self)
    }
}

extension PageTabBar: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: false)
        tabBarDelegate?.pageTabBar(self, didSelected: indexPath.row)
    }
}

extension UICollectionView {
    package func rowSequence(for section: Int) -> some Sequence<Int> {
        guard section >= 0, numberOfSections > section else {
            return (0..<0)
        }
        let numberOfRows = numberOfItems(inSection: section)
        return (0..<numberOfRows)
    }
}
