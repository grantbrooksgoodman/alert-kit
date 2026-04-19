//
//  InspectionDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

public extension AlertKit {
    /// An interface for resolving views used as popover anchors in
    /// action sheets.
    ///
    /// Implement this protocol to map integer tags to views in your
    /// interface. AlertKit calls ``sourceItem(_:)`` when an
    /// ``ActionSheet`` needs to resolve a ``ActionSheet/SourceItem``
    /// for popover presentation.
    ///
    /// Register your implementation through
    /// ``Config/registerInspectionDelegate(_:)``:
    ///
    /// ```swift
    /// AlertKit.config.registerInspectionDelegate(myDelegate)
    /// ```
    @MainActor
    protocol InspectionDelegate {
        /// Returns the view associated with the given tag, or `nil`
        /// if no view is found.
        ///
        /// - Parameter tag: An integer that identifies the view.
        ///
        /// - Returns: The view to use as the popover's anchor, or
        ///   `nil`.
        func sourceItem(_ tag: Int) -> UIView?
    }
}
