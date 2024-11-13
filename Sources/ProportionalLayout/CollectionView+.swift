import UIKit

extension UICollectionView {
    package var sectionSequence: any RandomAccessCollection<Int> {
        let numberOfSections = numberOfSections
        return (0..<numberOfSections)
    }
    
    package func rowSequence(for section: Int) -> any RandomAccessCollection<Int> {
        let numberOfRows = numberOfItems(inSection: section)
        return (0..<numberOfRows)
    }
    
    package var safeAreaSize: CGSize {
        let height = bounds.height - safeAreaInsets.top - safeAreaInsets.bottom
        let width = bounds.width - safeAreaInsets.left - safeAreaInsets.right
        return CGSize(width: width, height: height)
    }
}
