import UIKit
import os

open class PageViewController: WorkaroundCollectionViewController {
    public weak var dataSource: (any PageViewControllerDataSource)? = nil
    
    public let pageTabBar = PageTabBar()
    var hostedViewControllers: [IndexPath : UIViewController] = [:]
    
    public var itemContentInsets: UIEdgeInsets = .zero {
        didSet {
            reloadData()
        }
    }
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    public init() {
        super.init(collectionViewLayout: .paging())
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        super.loadView()
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTabBar.tabBarDelegate = self
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        removeHostedViewController(at: indexPath)
        cell.contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        if let contentViewController = dataSource?.viewController(for: self, at: indexPath.section) {
            let viewController = PageItemViewController(viewController: contentViewController)
            viewController.additionalSafeAreaInsets = itemContentInsets
            
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
    
    open override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = pageTabBar.contentOffset
        let width = pageTabBar.bounds.size.width
        
        guard width > 0 else { return }
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
    
    var percentComplete: CGFloat {
        let width = collectionView.bounds.size.width
        guard width > 0 else { return 0.0 }
        let value = collectionView.contentOffset.x / width
        guard !value.isNaN && value.isFinite else { return 0.0 }
        let maxValue = CGFloat(numberOfSections(in: collectionView) - 1)
        let minValue = 0.0
        guard maxValue > 0 else { return 0.0 }
        let range = minValue...maxValue
        let clampedValue = min(range.upperBound, max(range.lowerBound, value))
        return clampedValue
    }
    
    var indexPathForCenterItem: IndexPath? {
        let x = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let y = collectionView.bounds.height / 2
        return collectionView.indexPathForItem(at: CGPoint(x: x, y: y))
    }
    
    func update(_ percentComplete: Double) {
        pageTabBar.setIndicator(percentComplete)
        setPreferredContentScrollView(percentComplete)
    }
    
    func setPreferredContentScrollView(_ percentComplete: Double) {
        let index = Int(percentComplete.rounded())
        let indexPath = IndexPath(item: 0, section: index)
        let viewController = hostedViewControllers[indexPath]
        let contentScrollView = viewController?.contentScrollView(for: .top)
        let scrollView = contentScrollView ?? (viewController?.view as? UIScrollView)
        setContentScrollView(scrollView, for: [.top, .bottom])
    }
    
    public func reloadData() {
        guard isViewLoaded else { return }
        hostedViewControllers.values.forEach({ detachHostedViewController($0) })
        hostedViewControllers.removeAll()
        CATransaction.begin()
        CATransaction.setCompletionBlock { [unowned self] in
            update(percentComplete)
            pageTabBar.indicatorView.isHidden = numberOfSections(in: collectionView) == 0
        }
        pageTabBar.reloadData()
        collectionView.reloadData()
        CATransaction.commit()
    }
}

extension PageViewController: PageTabBarDelegate {
    func pageTabBar(_ pageTabBar: PageTabBar, didSelected index: Int) {
        collectionView.scrollToItem(
            at: IndexPath(row: 0, section: index),
            at: .centeredHorizontally,
            animated: true
        )
        // 既に選択済みのアイテムを選択するとスクロールが発生しないので１度呼ぶ
        pageTabBar.setIndicator(percentComplete)
    }
}

private extension PageViewController {
    func removeHostedViewController(at indexPath: IndexPath) {
        guard let viewController = hostedViewControllers.removeValue(forKey: indexPath) else { return }
        detachHostedViewController(viewController)
    }
    
    func detachHostedViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
