import Testing
import UIKit

@testable import Pager

@Suite(.serialized) @MainActor
struct PagerTests {
    @Test(arguments: [
        UIEdgeInsets.zero,
        UIEdgeInsets(top: 12, left: 7, bottom: 9, right: 11),
        UIEdgeInsets(top: 0, left: -96, bottom: 0, right: -160),
    ])
    func horizontalSafeAreaRemainsConstantWhilePaging(itemInsets: UIEdgeInsets) async throws {
        let children = (0..<3).map { _ in SafeAreaPageViewController() }
        let pages = children.enumerated()
            .map { index, child in
                Page(
                    id: "page-\(index)",
                    title: "Page \(index)",
                    viewControllerProvider: { _ in child }
                )
            }
        let pager = PageViewController(pages: pages)
        pager.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 32)
        pager.itemContentInsets = itemInsets
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
        window.frame = try #require(window.windowScene).coordinateSpace.bounds
        window.rootViewController = pager
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        for _ in 0..<5 {
            await Task.yield()
            window.layoutIfNeeded()
        }
        let expected = pager.view.safeAreaInsets
        #expect(expected.left >= 48)
        #expect(expected.right >= 32)
        let width = pager.collectionView.bounds.width
        for pagerInsets in [
            UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 32),
            UIEdgeInsets(top: 16, left: 24, bottom: 8, right: 64),
            .zero,
        ] {
            pager.additionalSafeAreaInsets = pagerInsets
            window.layoutIfNeeded()
            var expected = pager.view.safeAreaInsets
            expected.left = expected.left + max(0, itemInsets.left)
            expected.right = expected.right + max(0, itemInsets.right)
            for position in [0.0, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0, 1.5, 2.0, 1.0, 0.0] {
                pager.collectionView.contentOffset.x = width * position
                window.layoutIfNeeded()
                #expect(!pager.collectionView.visibleCells.isEmpty)
                for cell in pager.collectionView.visibleCells {
                    guard let indexPath = pager.collectionView.indexPath(for: cell) else {
                        continue
                    }
                    let child = children[indexPath.item]
                    child.view.layoutIfNeeded()
                    #expect(
                        abs(
                            child.scrollView.adjustedContentInset.left - expected.left
                        ) < 1
                    )
                    #expect(
                        abs(
                            child.scrollView.adjustedContentInset.right - expected.right
                        ) < 1
                    )
                    #expect(abs(child.view.safeAreaInsets.top - expected.top - itemInsets.top) < 1)
                    #expect(
                        abs(child.view.safeAreaInsets.bottom - expected.bottom - itemInsets.bottom)
                            < 1,
                        "position \(position): child \(child.view.safeAreaInsets), parent \(expected), item \(itemInsets)"
                    )
                    #expect(
                        abs(child.view.safeAreaInsets.left - expected.left) < 1,
                        "position \(position), page \(indexPath.item), left \(child.view.safeAreaInsets)"
                    )
                    #expect(
                        abs(child.view.safeAreaInsets.right - expected.right)
                            < 1,
                        "position \(position), page \(indexPath.item), right \(child.view.safeAreaInsets)"
                    )
                }
            }
        }
    }
}

@MainActor
private final class SafeAreaPageViewController: UIViewController {
    let scrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInsetAdjustmentBehavior = .always
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        scrollView.contentSize = CGSize(width: 800, height: 2000)
    }
}
