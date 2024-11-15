import UIKit
import os

// https://www.ackee.agency/blog/how-to-write-custom-uicollectionviewlayout-with-real-self-sizing-support
package final class ProportionalCollectionViewLayout: UICollectionViewLayout {
    @MainActor
    private struct LayoutItem: Sendable {
        var x: CGFloat
        var width: CGFloat
        var zIndex: Int
        
        func attributes(indexPath: IndexPath, collectionViewHeight: CGFloat) -> UICollectionViewLayoutAttributes {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(
                x: x,
                y: 0,
                width: width,
                height: collectionViewHeight
            )
            attributes.zIndex = zIndex
            return attributes
        }
    }
    
    enum LengthComponent: Equatable, Sendable {
        case safeAreaInset(CGFloat)
        case sectionInset(CGFloat)
        case item(CGFloat)
        case spacing(CGFloat)
        
        var value: CGFloat {
            switch self {
            case .safeAreaInset(let value): value
            case .sectionInset(let value): value
            case .item(let value): value
            case .spacing(let value): value
            }
        }
        
        var isContent: Bool {
            switch self {
            case .item, .spacing:
                true
            default:
                false
            }
        }
        
        var isItem: Bool {
            switch self {
            case .item:
                true
            default:
                false
            }
        }
        
        var isSpacing: Bool {
            switch self {
            case .spacing:
                true
            default:
                false
            }
        }
        
        var isInset: Bool {
            switch self {
            case .safeAreaInset, .sectionInset:
                true
            default:
                false
            }
        }
    }
    
    func width(for components: [LengthComponent]) -> CGFloat {
        components.map(\.value).reduce(0, +)
    }
    
    func contentWidth(for components: [LengthComponent]) -> CGFloat {
        width(for: components.filter(\.isContent))
    }
    
    func availableWidth(for components: [LengthComponent], in collectionView: UICollectionView) -> CGFloat {
        collectionView.bounds.width - width(for: components.filter(\.isInset))
    }
    
    public var estimatedItemWidth: CGFloat = 200
    
    public var minimumSpacing: CGFloat = 10
    
    public var sectionInset: UIEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
    
    private var contentSize: CGSize = .zero

    public override var collectionViewContentSize: CGSize {
        contentSize
    }
    
    private var cachedAttributes = [IndexPath : LayoutItem]()
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    package override func prepare() {
        super.prepare()
        
        let lengthComponents = prepareForFill(
            collectionView: collectionView!
        )
        
        contentSize.width = max(collectionView!.safeAreaSize.width, width(for: lengthComponents))
        contentSize.height = collectionView!.safeAreaSize.height
        
        // workaround: iOS 17 crashes with the following error:
        // Thread 1: Fatal error: <PageTabBar 0x600000c84750> is stuck in a recursive layout loop. This can happen when self-sizing views do not return consistent sizes, or the collection view's frame/bounds/contentOffset is being constantly adjusted. To debug this issue, check the Console app for logs in the "UICollectionViewFeedbackLoopDebugger" category.
        if #available(iOS 18.0, *) {
            let availableWidth = availableWidth(for: lengthComponents, in: collectionView!)
            let prefferedDistribution = prefferedDistribution(
                lengthComponents: lengthComponents,
                collectionView: collectionView!
            )
            switch prefferedDistribution {
            case .fill:
                break
            case .fillProportionally:
                prepareForFillProportionally(
                    collectionView: collectionView!,
                    contentWidth: contentWidth(for: lengthComponents),
                    availableWidth: availableWidth
                )
            case .fillEqually:
                let fillEquallyItemWidth = fillEquallyItemWidth(
                    lengthComponents: lengthComponents,
                    collectionView: collectionView!
                )
                prepareForFillEqually(
                    collectionView: collectionView!,
                    itemWidth: fillEquallyItemWidth
                )
            }
        }
    }
    
    func prefferedDistribution(
        lengthComponents: [LengthComponent],
        collectionView: UICollectionView
    ) -> PrefferedDistribution {
        if width(for: lengthComponents) <= collectionView.safeAreaSize.width {
            let maxItemWidth = lengthComponents.filter(\.isContent).map(\.value).max() ?? 0
            let fillEquallyItemWidth = fillEquallyItemWidth(
                lengthComponents: lengthComponents,
                collectionView: collectionView
            )
            if maxItemWidth <= fillEquallyItemWidth {
                return .fillEqually
            } else {
                return .fillProportionally
            }
        } else {
            return .fill
        }
    }
    
    func fillEquallyItemWidth(
        lengthComponents: [LengthComponent],
        collectionView: UICollectionView
    ) -> CGFloat {
        let spacingWidth = lengthComponents.filter(\.isSpacing).map(\.value).reduce(0, +)
        let availableWidth = availableWidth(for: lengthComponents, in: collectionView) - spacingWidth
        let itemCount = lengthComponents.count(where: \.isItem)
        return availableWidth / CGFloat(itemCount)
    }
    
    enum PrefferedDistribution: Sendable {
        case fill
        case fillProportionally
        case fillEqually
    }
    
    func prepareForFill(
        collectionView: UICollectionView
    ) -> [LengthComponent] {
        var lengthComponents: [LengthComponent] = []
        var zIndex = 1
        
        lengthComponents.append(.safeAreaInset(collectionView.safeAreaInsets.left))
        for section in collectionView.sectionSequence {
            lengthComponents.append(.sectionInset(sectionInset.left))
            
            for row in collectionView.rowSequence(for: section) {
                let indexPath = IndexPath(row: row, section: section)
                
                if var layoutItem = cachedAttributes[indexPath] {
                    layoutItem.x = width(for: lengthComponents)
                    layoutItem.zIndex = zIndex
                    cachedAttributes[indexPath] = layoutItem
                    lengthComponents.append(.item(layoutItem.width))
                } else {
                    let layoutItem = LayoutItem(
                        x: width(for: lengthComponents),
                        width: estimatedItemWidth,
                        zIndex: zIndex
                    )
                    cachedAttributes[indexPath] = layoutItem
                    lengthComponents.append(.item(layoutItem.width))
                }
                
                lengthComponents.append(.spacing(minimumSpacing))
                
                zIndex += 1
            }
            if case .spacing = lengthComponents.last {
                lengthComponents.removeLast()
            }
            lengthComponents.append(.sectionInset(sectionInset.right))
        }
        lengthComponents.append(.safeAreaInset(collectionView.safeAreaInsets.right))
        
        return lengthComponents
    }
    
    func prepareForFillEqually(
        collectionView: UICollectionView,
        itemWidth: CGFloat
    ) {
        var lengthComponents: [LengthComponent] = []
        lengthComponents.append(.safeAreaInset(collectionView.safeAreaInsets.left))
        for section in collectionView.sectionSequence {
            lengthComponents.append(.sectionInset(sectionInset.left))
            
            for row in collectionView.rowSequence(for: section) {
                let indexPath = IndexPath(row: row, section: section)
                let width = itemWidth
                cachedAttributes[indexPath]?.width = width
                cachedAttributes[indexPath]?.x = self.width(for: lengthComponents)
                lengthComponents.append(.item(width))
                lengthComponents.append(.spacing(minimumSpacing))
            }
            if case .spacing = lengthComponents.last {
                lengthComponents.removeLast()
            }
            lengthComponents.append(.sectionInset(sectionInset.right))
        }
        lengthComponents.append(.safeAreaInset(collectionView.safeAreaInsets.right))
    }
    
    func prepareForFillProportionally(
        collectionView: UICollectionView,
        contentWidth: CGFloat,
        availableWidth: CGFloat
    ) {
        var lengthComponents: [LengthComponent] = []
        lengthComponents.append(.safeAreaInset(collectionView.safeAreaInsets.left))
        for section in collectionView.sectionSequence {
            lengthComponents.append(.sectionInset(sectionInset.left))
            
            for row in collectionView.rowSequence(for: section) {
                let indexPath = IndexPath(row: row, section: section)
                let cachedItem = cachedAttributes[indexPath]!
                let ratio = cachedItem.width / contentWidth
                let width = availableWidth * ratio
                cachedAttributes[indexPath]?.width = width
                cachedAttributes[indexPath]?.x = self.width(for: lengthComponents)
                lengthComponents.append(.item(width))
                lengthComponents.append(.spacing(minimumSpacing))
            }
            if case .spacing = lengthComponents.last {
                lengthComponents.removeLast()
            }
            lengthComponents.append(.sectionInset(sectionInset.right))
        }
        lengthComponents.append(.safeAreaInset(collectionView.safeAreaInsets.right))
    }
    
    package override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        cachedAttributes.reduce(into: [UICollectionViewLayoutAttributes]()) { acc, item in
            let itemAttrs = item.value.attributes(
                indexPath: item.key,
                collectionViewHeight: contentSize.height
            )
            
            if rect.intersects(itemAttrs.frame) {
                acc.append(itemAttrs)
            }
        }
    }
    
    package override func layoutAttributesForItem(
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        cachedAttributes[indexPath]?.attributes(
            indexPath: indexPath,
            collectionViewHeight: contentSize.height
        )
    }

    package override func shouldInvalidateLayout(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
        originalAttributes.frame.width != preferredAttributes.frame.width
    }
    
    package override func invalidationContext(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(
            forPreferredLayoutAttributes: preferredAttributes,
            withOriginalAttributes: originalAttributes
        )
        let widthDiff = originalAttributes.frame.width - preferredAttributes.frame.width
        
        let isAboveTopEdge = preferredAttributes.frame.minX < (collectionView?.bounds.minX ?? 0)
        context.contentOffsetAdjustment.x -= isAboveTopEdge ? -widthDiff : 0
        
        context.contentSizeAdjustment.width -= widthDiff
        
        cachedAttributes[preferredAttributes.indexPath]?.width = preferredAttributes.frame.width
        return context
    }
    
    package override func invalidateLayout(
        with context: UICollectionViewLayoutInvalidationContext
    ) {
        super.invalidateLayout(with: context)
        
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            cachedAttributes.removeAll()
        }
    }
}
