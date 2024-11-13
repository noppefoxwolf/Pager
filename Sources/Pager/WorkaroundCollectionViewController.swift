import UIKit

open class WorkaroundCollectionViewController: UICollectionViewController {
    // workaround: Adjust contentOffset after rotation
    // See also: https://stackoverflow.com/a/43322706
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let collectionView else { return }
        let offset = collectionView.contentOffset
        let width = collectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        coordinator.animate(
            alongsideTransition: { (context) in
                collectionView.reloadData()
                collectionView.setContentOffset(newOffset, animated: false)
            },
            completion: nil
        )
    }
}
