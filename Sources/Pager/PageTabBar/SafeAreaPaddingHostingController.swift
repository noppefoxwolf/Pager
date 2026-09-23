import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class SafeAreaPaddingState {
    var insets = EdgeInsets()
}

struct SafeAreaPaddingView<Content: View>: View {
    let rootView: Content
    let state: SafeAreaPaddingState
    let ignoredEdges: Edge.Set

    var body: some View {
        rootView
            .safeAreaPadding(
                .top,
                ignoredEdges.contains(.top) ? 0 : state.insets.top
            )
            .safeAreaPadding(
                .leading,
                ignoredEdges.contains(.leading) ? 0 : state.insets.leading
            )
            .safeAreaPadding(
                .bottom,
                ignoredEdges.contains(.bottom) ? 0 : state.insets.bottom
            )
            .safeAreaPadding(
                .trailing,
                ignoredEdges.contains(.trailing) ? 0 : state.insets.trailing
            )
    }
}

@MainActor
final class SafeAreaPaddingHostingController<Content: View>: UIHostingController<SafeAreaPaddingView<Content>> {
    private let safeAreaPadding: SafeAreaPaddingState

    init(rootView: Content, ignoreSafeAreaPadding: Edge.Set) {
        let safeAreaPadding = SafeAreaPaddingState()
        self.safeAreaPadding = safeAreaPadding

        super.init(
            rootView: SafeAreaPaddingView(
                rootView: rootView,
                state: safeAreaPadding,
                ignoredEdges: ignoreSafeAreaPadding
            )
        )

        safeAreaRegions = []
        sizingOptions = [.intrinsicContentSize]
        view.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSafeAreaPadding()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateSafeAreaPadding()
    }

    private func updateSafeAreaPadding() {
        let uiInsets = view.safeAreaInsets
        let newInsets = EdgeInsets(
            top: uiInsets.top,
            leading: uiInsets.left,
            bottom: uiInsets.bottom,
            trailing: uiInsets.right
        )

        guard safeAreaPadding.insets != newInsets else { return }
        safeAreaPadding.insets = newInsets
    }
}
