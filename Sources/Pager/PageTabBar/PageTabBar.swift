import SwiftUI
import UIKit

/// UIKit view that hosts the SwiftUI page tab bar.
@MainActor
public final class PageTabBar: ViewControllerContainerView {

    public convenience init(state: PageTabBarState) {
        self.init(state: state) { EmptyView() }
    }

    /// Creates a tab bar with fixed content at its trailing edge.
    /// The page tabs use the remaining width and scroll independently.
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
        CGSize(width: UIView.noIntrinsicMetric, height: 34)
    }
}

@MainActor
private struct PageTabBarContent<Trailing: View>: View {
    let trailing: Trailing

    var body: some View {
        HStack(spacing: 0) {
            PageTabBarView()
                .frame(maxWidth: .infinity)
            HStack(spacing: 10) {
                trailing
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(.trailing, Trailing.self == EmptyView.self ? 0 : 20)
        }
        .frame(height: 34)
    }
}
