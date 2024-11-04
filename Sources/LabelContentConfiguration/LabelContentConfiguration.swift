import UIKit

package struct LabelContentConfiguration: UIContentConfiguration {
    package var text: String = ""
    package var textProperties: UIConfigurationTextAttributesTransformer? = nil

    package func makeContentView() -> UIView & UIContentView {
        LabelContentView(self)
    }

    package func updated(for state: UIConfigurationState) -> LabelContentConfiguration {
        self
    }
}
