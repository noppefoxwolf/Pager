import UIKit
import os

open class PageViewController: WorkaroundCollectionViewController {
    public weak var dataSource: (any PageViewControllerDataSource)? = nil
    
    public let pageTabBar = PageTabBar()
    var hostedViewControllers: [IndexPath : UIViewController] = [:]
    let topBluringView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    let bottomBluringView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    public init() {
        let layout = UICollectionViewCompositionalLayout.paging(column: 1)
        super.init(collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public var columnCount: Int = 1 {
        didSet {
            let layout = UICollectionViewCompositionalLayout.paging(column: columnCount)
            collectionView.setCollectionViewLayout(layout, animated: false)
            topBluringView.isHidden = columnCount == 1
            bottomBluringView.isHidden = columnCount == 1
        }
    }
    
    open override func loadView() {
        super.loadView()
        
        topBluringView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBluringView)
        NSLayoutConstraint.activate([
            topBluringView.topAnchor.constraint(equalTo: view.topAnchor),
            topBluringView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBluringView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: topBluringView.trailingAnchor),
        ])
        
        bottomBluringView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBluringView)
        NSLayoutConstraint.activate([
            bottomBluringView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBluringView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBluringView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: bottomBluringView.trailingAnchor),
        ])
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    var percentComplete: CGFloat {
        let value = collectionView.contentOffset.x / collectionView.visibleSize.width
        return value.isNaN ? 0.0 : value
    }
    
    var indexPathForCenterItem: IndexPath? {
        let x = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let y = collectionView.bounds.height / 2
        return collectionView.indexPathForItem(at: CGPoint(x: x, y: y))
    }
    
    func update(_ percentComplete: Double) {
        pageTabBar.setIndicator(percentComplete, columnCount: columnCount)
        
        if columnCount == 1 {
            let index = Int(percentComplete.rounded())
            let indexPath = IndexPath(item: 0, section: index)
            let viewController = hostedViewControllers[indexPath]
            let topContentScrollView = viewController?.contentScrollView(for: .top)
            let topScrollView = topContentScrollView ?? (viewController?.view as? UIScrollView)
            setContentScrollView(topScrollView, for: .top)
            
            let bottomcontentScrollView = viewController?.contentScrollView(for: .bottom)
            let bottomScrollView = bottomcontentScrollView ?? (viewController?.view as? UIScrollView)
            setContentScrollView(bottomScrollView, for: .bottom)
        } else {
            setContentScrollView(nil, for: .all)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTabBar.tabBarDelegate = self
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        update(percentComplete)
    }
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        super.scrollViewDidEndDecelerating(scrollView)
        update(percentComplete)
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
    
    public func reloadData() {
        hostedViewControllers.values.forEach({ $0.removeFromParent() })
        hostedViewControllers = [:]
        CATransaction.begin()
        CATransaction.setCompletionBlock { [unowned self] in
            if let indexPathForCenterItem {
                pageTabBar.setIndicator(
                    Double(indexPathForCenterItem.section),
                    columnCount: columnCount
                )
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
