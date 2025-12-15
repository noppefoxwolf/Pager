# Pager

UIKit pager view controller with a scroll-synced tab bar and indicator, built on compositional layout and diffable data sources.

![](.github/sample.gif)

## Features
- Host any `UIViewController` per page via `Page` providers; works inside navigation or tab stacks.
- Scroll-synced tab bar whose indicator width follows the current label; optional selection haptics.
- Programmatic or observed selection through `selectedPage` with safe pre-load application.
- Safe rotation/resizing: keeps the current page and indicator aligned on size changes.
- Customizable content insets per page (`itemContentInsets`) for floating headers / safe areas.
- Targets iOS 17+ and visionOS 1+ (Swift tools 6.2).

## Installation (Swift Package Manager)
Add the package to Xcode or your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/noppefoxwolf/Pager.git", from: "0.1.0")
]
```

Then add `Pager` to your target dependencies.

## Quick start
```swift
import Pager
import SwiftUI

final class PagesViewController: PageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        pages = [
            Page(id: "home", title: "Home") { page in
                UIHostingController(rootView: Text(page.title))
            },
            Page(id: "list", title: "List") { _ in
                TableViewController(style: .plain)   // any UIViewController works
            }
        ]

        // Programmatically select a page (can be set before view loads)
        selectedPage = pages.first

        // Place the tab bar beneath the navigation bar
        let interaction = UIScrollEdgeElementContainerInteraction()
        interaction.scrollView = collectionView
        interaction.edge = .top
        pageTabBar.addInteraction(interaction)

        collectionView.superview?.addSubview(pageTabBar)
        pageTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageTabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageTabBar.heightAnchor.constraint(equalToConstant: 34)
        ])

        // Keep page content clear of the tab bar
        itemContentInsets.top = 34
    }
}
```

`pages` can be updated at runtime (append/remove) and the pager refreshes automatically through diffable data sources; `selectedPage` tracks the visible page and can be set to jump.

## Key types
- `PageViewController`: horizontally paged collection view controller exposing `pages`, `selectedPage`, `pageTabBar`, `itemContentInsets`, and `reloadData()`.
- `Page`: page descriptor containing `id`, `title`, and a `viewControllerProvider`.
- `PageTabBar`: horizontally scrolling tab bar with an indicator that tracks scroll progress and emits selection haptics.

## Examples
Open `Playground.swiftpm` to try the interactive sample (dynamic tab add/remove, table/collection content). The preview GIF in `.github/sample.gif` was captured from this playground.

## Testing
See `TESTING.md` for running the iOS simulator tests with `xcodebuild`.

## License
MIT - see the [LICENSE](LICENSE) file.
