import UIKit
import Foundation
import os

@MainActor
final class FeedbackGenerator {
    #if os(iOS)
    let feedbackGenerator = UISelectionFeedbackGenerator()
    #endif
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    func prepare() {
        #if os(iOS)
        feedbackGenerator.prepare()
        #endif
    }
    
    func selectionChanged() {
        #if os(iOS)
        feedbackGenerator.selectionChanged()
        #endif
    }
}

