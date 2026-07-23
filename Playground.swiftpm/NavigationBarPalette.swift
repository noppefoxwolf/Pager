import UIKit

extension UINavigationItem {
    public func setBottomPalette(_ palette: NavigationBarPalette) {
        let selector = Selector(Strings.setBottomPalette)
        if responds(to: selector) {
            perform(selector, with: palette.view)
        }
    }
}

public final class NavigationBarPalette {
    public let view: UIView

    public init?(contentView: UIView) {
        guard let paletteViewType = NSClassFromString(Strings.navigationBarPalette) as? UIView.Type
        else {
            return nil
        }

        let allocSelector = NSSelectorFromString(Strings.alloc)
        guard paletteViewType.responds(to: allocSelector),
            let allocatedPaletteView = paletteViewType.perform(allocSelector)?
                .takeUnretainedValue(),
            let paletteView = allocatedPaletteView as? UIView
        else {
            return nil
        }

        let initSelector = Selector(Strings.initWithContentView)
        guard paletteView.responds(to: initSelector),
            let initializedPaletteView = paletteView.perform(
                initSelector,
                with: contentView
            )?
            .takeUnretainedValue() as? UIView
        else {
            return nil
        }

        view = initializedPaletteView
    }

    public func setPreferredHeight(_ height: CGFloat) {
        let selector = Selector(Strings.setPreferredHeight)
        if view.responds(to: selector) {
            view.perform(selector, with: height)
        }
    }
}

private enum Strings {
    static let alloc = "alloc"
    static let navigationBarPalette = "UINavigationBarPalette"
    static let initWithContentView = "initWithContentView:"
    static let setBottomPalette = "_setBottomPalette:"
    static let setPreferredHeight = "setPreferredHeight:"
}
