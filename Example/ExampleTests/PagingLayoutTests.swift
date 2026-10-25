import Pager
import Testing
import UIKit

@Suite(.serialized) @MainActor
struct PagingLayoutTests {
    @Test(arguments: [
        UIEdgeInsets.zero,
        UIEdgeInsets(top: 12, left: 7, bottom: 9, right: 11),
        UIEdgeInsets(top: 0, left: -96, bottom: 0, right: -160),
    ])
    func animatedPagingUpdatesSafeAreasWithoutForcedLayout(contentInsets: UIEdgeInsets) async throws
    {
        let children = (0..<3).map { _ in ObservedPageViewController() }
        let pager = PageViewController(
            pages: children.enumerated()
                .map { index, child in
                    Page(
                        id: "page-\(index)",
                        title: "Page \(index)",
                        viewControllerProvider: { _ in child }
                    )
                }
        )
        pager.itemContentInsets = contentInsets
        pager.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 32)
        let scene = try #require(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
        )
        let window = UIWindow(windowScene: scene)
        window.rootViewController = pager
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        for _ in 0..<100 where pager.collectionView.contentSize.width == 0 {
            try await Task.sleep(for: .milliseconds(10))
        }
        let width = pager.collectionView.bounds.width
        try #require(width > 0)
        try #require(pager.collectionView.numberOfItems(inSection: 0) == children.count)
        var intermediateSamples = 0
        var mismatches: [String] = []
        for destination in [1, 2, 0] {
            if destination == 2 {
                // Change safe area without resizing the window.
                pager.additionalSafeAreaInsets = UIEdgeInsets(
                    top: 0,
                    left: 24,
                    bottom: 0,
                    right: 64
                )
            }
            pager.collectionView.setContentOffset(
                CGPoint(x: width * CGFloat(destination), y: 0),
                animated: true
            )
            for _ in 0..<60 {
                try await Task.sleep(for: .milliseconds(10))
                let position = pager.collectionView.contentOffset.x / width
                if abs(position - position.rounded()) > 0.01 { intermediateSamples += 1 }
                var expected = pager.view.safeAreaInsets
                expected.top += contentInsets.top
                expected.bottom += contentInsets.bottom
                expected.left = expected.left + max(0, contentInsets.left)
                expected.right = expected.right + max(0, contentInsets.right)
                #expect(!pager.collectionView.visibleCells.isEmpty)
                for cell in pager.collectionView.visibleCells {
                    guard let indexPath = pager.collectionView.indexPath(for: cell) else {
                        continue
                    }
                    let child = children[indexPath.item]
                    let actual = child.view.safeAreaInsets
                    let adjusted = child.scrollView.adjustedContentInset
                    if abs(actual.left - expected.left) > 1
                        || abs(actual.right - expected.right) > 1
                        || abs(actual.top - expected.top) > 1
                        || abs(actual.bottom - expected.bottom) > 1
                        || abs(adjusted.left - expected.left) > 1
                        || abs(adjusted.right - expected.right) > 1
                    {
                        mismatches.append(
                            "position \(position), page \(indexPath.item): \(actual), expected \(expected)"
                        )
                    }
                }
            }
            #expect(abs(pager.collectionView.contentOffset.x - width * CGFloat(destination)) < 1)
        }
        #expect(intermediateSamples > 5)
        #expect(mismatches.first == nil, "\(mismatches.prefix(5))")
        // Safe-area changes must also propagate while paging is idle.
        pager.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 16)
        try await Task.sleep(for: .milliseconds(100))
        let currentChild = children[0]
        let expected = pager.view.safeAreaInsets
        #expect(
            abs(currentChild.view.safeAreaInsets.left - expected.left - max(0, contentInsets.left))
                < 1
        )
        #expect(
            abs(
                currentChild.view.safeAreaInsets.right - expected.right
                    - max(0, contentInsets.right)
            ) < 1
        )
        #expect(
            abs(
                currentChild.scrollView.adjustedContentInset.left - expected.left
                    - max(0, contentInsets.left)
            ) < 1
        )
        #expect(
            abs(
                currentChild.scrollView.adjustedContentInset.right - expected.right
                    - max(0, contentInsets.right)
            ) < 1
        )
        let settledLayoutCount = children.reduce(0) { $0 + $1.layoutCount }
        try await Task.sleep(for: .milliseconds(200))
        #expect(children.reduce(0) { $0 + $1.layoutCount } == settledLayoutCount)
    }
}

@MainActor
private final class ObservedPageViewController: UIViewController {
    let scrollView = UIScrollView()
    var layoutCount = 0

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutCount += 1
    }

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
