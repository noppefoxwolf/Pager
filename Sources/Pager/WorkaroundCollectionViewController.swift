import UIKit

open class WorkaroundCollectionViewController: CollectionViewController {
    // workaround: Adjust contentOffset after rotation
    // See also: https://stackoverflow.com/a/43322706
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = collectionView.contentOffset
        let width = collectionView.bounds.size.width
        
        guard width > 0 else { return }
        let index = round(offset.x / width)
        guard index.isNormal else { return }
        
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        coordinator.animate(
            alongsideTransition: { [weak collectionView] (context) in
                collectionView?.reloadData()
                collectionView?.setContentOffset(newOffset, animated: false)
            },
            completion: nil
        )
    }
}

// workaround: Even if UIObservationTrackingEnabled is enabled in iOS18, UICollectionViewController does not monitor state, so you need to create your own.
open class CollectionViewController: UIViewController, UICollectionViewDelegate {
    public let collectionView: UICollectionView

    public init(collectionViewLayout: UICollectionViewLayout) {
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        super.init(nibName: nil, bundle: nil)
        collectionView.delegate = self
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        view.backgroundColor = .systemBackground
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    open func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
    }
}
