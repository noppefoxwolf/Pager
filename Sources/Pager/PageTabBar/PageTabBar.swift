import SwiftUI
import UIKit

/// UIKit view that hosts the SwiftUI page tab bar.
@MainActor
public final class PageTabBar: ViewControllerContainerView {

    public convenience init(state: PageTabBarState) {
        self.init(state: state) { EmptyView() }
    }

    /// Creates a tab bar with fixed content at its trailing edge.
    /// Reserves safe-area space while the tabs scroll beneath the trailing content.
    public convenience init<Trailing: View>(
        state: PageTabBarState,
        trailingPadding: CGFloat = 10,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(state: state, trailingPadding: trailingPadding, leading: { EmptyView() }, trailing: trailing)
    }

    /// Creates a tab bar with fixed content at either edge.
    /// Omit `trailing` to provide only leading content.
    public init<Leading: View, Trailing: View>(
        state: PageTabBarState,
        leadingPadding: CGFloat = 10,
        trailingPadding: CGFloat = 10,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        let hostingController = SafeAreaPaddingHostingController(
            rootView: PageTabBarContent(
                leading: leading(),
                trailing: trailing(),
                leadingPadding: leadingPadding,
                trailingPadding: trailingPadding
            ).environment(state),
            ignoreSafeAreaPadding: .vertical
        )
        super.init(viewController: hostingController)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: PageTabBarView.height)
    }
}

@MainActor
private struct PageTabBarContent<Leading: View, Trailing: View>: View {
    let leading: Leading
    let trailing: Trailing
    let leadingPadding: CGFloat
    let trailingPadding: CGFloat

    var body: some View {
        PageTabBarView()
            .safeAreaInset(edge: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    leading
                        .padding(.horizontal, leadingPadding)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .safeAreaInset(edge: .trailing, spacing: 0) {
                HStack(spacing: 10) {
                    trailing
                        .padding(.horizontal, trailingPadding)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
    }
}
