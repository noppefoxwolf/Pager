import UIKit
import ViewControllerContentConfiguration
import os

open class PageViewController: WorkaroundCollectionViewController {
    public let pageTabBar = PageTabBarController()

    lazy var dataSource = UICollectionViewDiffableDataSource<Section, Page.ID>(
        collectionView: collectionView,
        cellProvider: { [unowned self] collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    )
    public weak var delegate: (any PageViewControllerDelegate)? = nil

    public var itemContentInsets: UIEdgeInsets = .zero {
        didSet {
            reconfigure()
        }
    }

    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )

    public var pages: [Page] = [] {
        didSet {
            pagesByID = Dictionary(uniqueKeysWithValues: pages.map { ($0.id, $0) })
            pageTabBar.pages = pages
            reloadData()
        }
    }

    // TODO: setPages

    public init(pages: [Page] = []) {
        self.pages = pages
        super.init(collectionViewLayout: .paging())
        pageTabBar.pages = pages
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
        _ = cellRegistration
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        pageTabBar.delegate = self
    }

    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        reloadData()
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        update(percentComplete)
    }

    private var pagesByID: [Page.ID: Page] = [:]

    lazy var cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Page.ID>(
        handler: { [unowned self] cell, indexPath, item in
            guard let page = pagesByID[item] else {
                cell.contentConfiguration = nil
                return
            }
            let contentViewController = page.viewController
            let viewController = PageItemViewController(viewController: contentViewController)
            viewController.additionalSafeAreaInsets = itemContentInsets
            cell.contentConfiguration = cell.viewControllerConfiguration(
                viewController: viewController,
                parent: self
            )
        }
    )

    var percentComplete: CGFloat {
        let width = collectionView.bounds.size.width
        guard width > 0 else { return 0.0 }
        let value = collectionView.contentOffset.x / width
        guard !value.isNaN && value.isFinite else { return 0.0 }
        let maxValue = CGFloat(pages.count - 1)
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
        pageTabBar.setTransitionProgress(percentComplete)
    }

    @MainActor
    public func reloadData() {
        guard isViewLoaded else { return }

        pagesByID = Dictionary(uniqueKeysWithValues: pages.map { ($0.id, $0) })

        var snapshot = NSDiffableDataSourceSnapshot<Section, Page.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pages.map(\.id), toSection: .main)
        snapshot.reconfigureItems(snapshot.itemIdentifiers)

        let diff = dataSource.snapshot().itemIdentifiers.difference(from: snapshot.itemIdentifiers)

        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self else { return }
            if !diff.isEmpty {
                delegate?.didFinishTransition(self)
            }
        }
        view.setNeedsLayout()
    }

    func reconfigure() {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        update(percentComplete)
    }

    open override func contentScrollView(for edge: NSDirectionalRectEdge) -> UIScrollView? {
        guard isViewLoaded else { return nil }
        guard let indexPath = indexPathForCenterItem else { return nil }
        let contentViewController = pages[indexPath.row].viewController
        let contentScrollView = contentViewController.contentScrollView(for: edge)
        return contentScrollView ?? contentViewController.rootScrollView
    }

    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.didFinishTransition(self)
    }

    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.didFinishTransition(self)
    }

    open override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        delegate?.willTransition(to: [pages[indexPath.row].viewController])
    }
}

extension PageViewController: PageTabBarControllerDelegate {
    public func pageTabBarController(_ controller: PageTabBarController, didSelect page: Page) {
        guard let index = pages.firstIndex(where: { $0.id == page.id }) else { return }
        collectionView.scrollToItem(
            at: IndexPath(row: index, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
}

private extension UIViewController {
    var rootScrollView: UIScrollView? {
        view as? UIScrollView
    }
}
