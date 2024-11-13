import UIKit

extension UICollectionViewLayout {
    static func paging(
        visibleItemsInvalidationHandler: @escaping
        NSCollectionLayoutSectionVisibleItemsInvalidationHandler
    ) -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        configuration.contentInsetsReference = .automatic
        return UICollectionViewCompositionalLayout(
            sectionProvider: { section, environment in
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 1
                )
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
                return section
            },
            configuration: configuration
        )
    }
}
