import UIKit
import os

open class PageViewController: WorkaroundCollectionViewController {
    public weak var dataSource: (any PageViewControllerDataSource)? = nil
    
    public let pageTabBar = PageTabBar()
    var hostedViewControllers: [IndexPath : UIViewController] = [:]
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    public init() {
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func loadView() {
        super.loadView()
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        typealias Handler = NSCollectionLayoutSectionVisibleItemsInvalidationHandler
        let handler: Handler = { [weak self] (items, point, environment) in
            let progress = point.x / environment.container.contentSize.width
            self?.onUpdatedPageProgress(progress)
        }
        let layout = UICollectionViewCompositionalLayout.paging(
            visibleItemsInvalidationHandler: handler
        )
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    func onUpdatedPageProgress(_ progress: Double) {
        pageTabBar.setIndicator(progress)
        
        let index = Int(progress.rounded())
        let indexPath = IndexPath(item: 0, section: index)
        let viewController = hostedViewControllers[indexPath]
        //dataSource?.viewController(for: self, at: index)
        let contentScrollView = viewController?.contentScrollView(for: .top)
        let scrollView = contentScrollView ?? (viewController?.view as? UIScrollView)
        setContentScrollView(scrollView, for: .top)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTabBar.tabBarDelegate = self
    }
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataSource?.numberOfViewControllers(in: self) ?? 0
    }
    
    open override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        1
    }
    
    open override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        if let viewController = dataSource?.viewController(for: self, at: indexPath.section) {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
            viewController.didMove(toParent: nil)
            
            viewController.willMove(toParent: self)
            addChild(viewController)
            hostedViewControllers[indexPath] = viewController
            cell.contentView.addSubview(viewController.view)
            viewController.didMove(toParent: self)
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                viewController.view.topAnchor.constraint(equalTo: cell.contentView.safeAreaLayoutGuide.topAnchor),
                cell.contentView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
                viewController.view.leadingAnchor.constraint(
                    equalTo: cell.contentView.safeAreaLayoutGuide.leadingAnchor
                ),
                cell.contentView.safeAreaLayoutGuide.trailingAnchor.constraint(
                    equalTo: viewController.view.trailingAnchor
                ),
            ])
        }
        return cell
    }
    
    var centerIndexPath: IndexPath? {
        let x = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let y = collectionView.bounds.height / 2
        return collectionView.indexPathForItem(at: CGPoint(x: x, y: y))
    }
    
    public func reloadData() {
        hostedViewControllers.values.forEach({ $0.removeFromParent() })
        hostedViewControllers = [:]
        CATransaction.begin()
        CATransaction.setCompletionBlock { [unowned self] in
            if let centerIndexPath {
                pageTabBar.setIndicator(Double(centerIndexPath.section))
            }
            pageTabBar.indicatorView.isHidden = numberOfSections(in: collectionView) == 0
        }
        pageTabBar.reloadData()
        collectionView.reloadData()
        CATransaction.commit()
    }
    
    open override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = pageTabBar.contentOffset
        let width = pageTabBar.bounds.size.width
        
        let index = round(offset.x / width)
        guard index.isNormal else { return }
        
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        coordinator.animate(
            alongsideTransition: { [unowned pageTabBar] (context) in
                pageTabBar.reloadData()
                pageTabBar.setContentOffset(newOffset, animated: false)
            },
            completion: nil
        )
    }
}

extension PageViewController: PageTabBarDelegate {
    func pageTabBar(_ pageTabBar: PageTabBar, didSelected index: Int) {
        collectionView.scrollToItem(
            at: IndexPath(row: 0, section: index),
            at: .centeredHorizontally,
            animated: true
        )
    }
}
