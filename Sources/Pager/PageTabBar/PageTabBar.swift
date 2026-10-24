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
    public init<Trailing: View>(
        state: PageTabBarState,
        @ViewBuilder trailing: () -> Trailing
    ) {
        let hostingController = SafeAreaPaddingHostingController(
            rootView: PageTabBarContent(trailing: trailing()).environment(state),
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
private struct PageTabBarContent<Trailing: View>: View {
    let trailing: Trailing

    var body: some View {
        PageTabBarView()
            .safeAreaInset(edge: .trailing, spacing: 0) {
                HStack(spacing: 10) {
                    trailing
                }
                .fixedSize(horizontal: true, vertical: false)
                .padding(.trailing, Trailing.self == EmptyView.self ? 0 : 20)
            }
    }
}
