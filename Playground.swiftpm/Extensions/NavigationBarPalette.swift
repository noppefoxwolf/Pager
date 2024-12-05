import UIKit

extension UINavigationItem {
    // https://twitter.com/sebjvidal/status/1748659522455937213?s=61&t=QkfPitI5Z7OEKMAvToTbCA
    public func setBottomPalette(_ palette: NavigationBarPalette) {
        let _setButtomPaletteSelector = Selector(("_setBottomPalette:"))
        if responds(to: _setButtomPaletteSelector) {
            perform(_setButtomPaletteSelector, with: palette.palette)
        }
    }
}

public final class NavigationBarPalette {
    let palette: UIView
    
    init(contentView: UIView) {
        let _UINavigationBarPalette = NSClassFromString("_UINavigationBarPalette") as! UIView.Type
        let palette = _UINavigationBarPalette.perform(NSSelectorFromString("alloc"))
            .takeUnretainedValue()
            .perform(Selector(("initWithContentView:")), with: contentView)
            .takeUnretainedValue()
        self.palette = palette as! UIView
    }
    
    func setPreferredHeight(_ height: CGFloat) {
        palette.perform(Selector(("setPreferredHeight:")), with: height)
    }
}
