# Pager

UIKit pager view controller with a scroll-synced tab bar and indicator, built on compositional layout and diffable data sources.

![](.github/sample.gif)

## Features
- Host any `UIViewController` per page via `Page` providers; works inside navigation or tab stacks.
- Scroll-synced tab bar whose indicator width follows the current label; optional selection haptics.
- Shared tab bar state through `PageViewController.state`, including page titles and transition progress.
- Safe rotation/resizing: keeps the current page and indicator aligned on size changes.
- Customizable content insets per page (`itemContentInsets`) for floating headers / safe areas.
- Targets iOS 18+ and visionOS 2+ (Swift tools 6.2).

## Installation (Swift Package Manager)
Add the package to Xcode or your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/noppefoxwolf/Pager.git", from: "0.1.0")
]
```

Then add `Pager` to your target dependencies.

## Compatibility note

On iOS 26 and later, the background blur of the navigation bar palette does not work correctly when `UIDesignRequiresCompatibility` is set to `true`. Set it to `false` (or remove the key) to use the palette background blur normally.

## Quick start
```swift
import Pager
import SwiftUI

final class PagesViewController: PageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let pageTabBar = PageTabBar(state: state)

        pages = [
            Page(id: "home", title: "Home") { page in
                UIHostingController(rootView: Text(page.title))
            },
            Page(id: "list", title: "List") { _ in
                TableViewController(style: .plain)   // any UIViewController works
            }
        ]

        // Build the tab bar from the pager's shared state.
        // Place it beneath the navigation bar.
        let interaction = UIScrollEdgeElementContainerInteraction()
        interaction.scrollView = collectionView
        interaction.edge = .top
        pageTabBar.addInteraction(interaction)

        view.addSubview(pageTabBar)
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

`pages` can be updated at runtime (append/remove) and the pager refreshes automatically through diffable data sources. The pager updates `state.position` while scrolling, and selecting a tab through `PageTabBar` scrolls the pager to the corresponding page.

Pass SwiftUI content to `trailing` to add fixed items beside the scrolling tabs:

```swift
let pageTabBar = PageTabBar(state: state) {
    Button("Add", systemImage: "plus") {
        // Add a page.
    }
    .labelStyle(.iconOnly)
}
```

The closure supports multiple views, including buttons and menus. The trailing content is placed using `safeAreaInset`. The scroll view extends beneath it, with a content inset that keeps the last tab accessible and a fade mask immediately before the trailing items. `PageTabBar(state:)` continues to show only the tabs.

Use `leading` for content at the other edge, either on its own or together with `trailing`:

```swift
let pageTabBar = PageTabBar(state: state) {
    Button("First Page", systemImage: "backward.end") {
        state.onSelect?(0)
    }
    .labelStyle(.iconOnly)
} trailing: {
    Button("Add", systemImage: "plus") {
        // Add a page.
    }
    .labelStyle(.iconOnly)
}

let leadingOnly = PageTabBar(state: state, leading: {
    Text("Pages")
})
```

Both edges use safe area insets, with 10 points of horizontal padding applied directly to the supplied content by default. Pass `leadingPadding` and `trailingPadding` to customize each edge independently:

```swift
let pageTabBar = PageTabBar(state: state, leadingPadding: 16, trailingPadding: 8) {
    Text("Pages")
} trailing: {
    Button("Add", systemImage: "plus") {
        // Add a page.
    }
    .labelStyle(.iconOnly)
}
```

## Key types
- `PageViewController`: horizontally paged collection view controller exposing `pages`, `state`, `itemContentInsets`, and `reloadData()`.
- `Page`: page descriptor containing `id`, `title`, and a `viewControllerProvider`.
- `PageTabBar`: UIKit `UIView & UIContentView` wrapping the SwiftUI tab bar; initialize it with `PageViewController.state`.
- `PageTabBarState`: shared observable state used by `PageViewController` and `PageTabBar`.

## Examples
Open `Example/Example.xcodeproj` to try the interactive sample (dynamic tab add/remove, table/collection content). The preview GIF in `.github/sample.gif` was captured from this example.

## Testing
See `TESTING.md` for running the iOS simulator tests with `xcodebuild`.

## License
MIT - see the [LICENSE](LICENSE) file.
