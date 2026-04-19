//
//  PresentationDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

public extension AlertKit {
    /// An interface for presenting alert controllers to the user
    /// using your app.
    ///
    /// Implement this protocol to control how AlertKit presents its
    /// alerts. Register your implementation through
    /// ``Config/registerPresentationDelegate(_:)``:
    ///
    /// ```swift
    /// AlertKit.config.registerPresentationDelegate(myDelegate)
    /// ```
    ///
    /// AlertKit calls ``present(_:)`` each time an alert is ready
    /// for display. Your implementation is responsible for presenting
    /// the `UIAlertController` on the appropriate view controller.
    ///
    /// - Important: AlertKit requires a registered presentation
    ///   delegate to present alerts. Without one, calls to
    ///   `present(translating:)` on any alert type have no visible
    ///   effect.
    @MainActor
    protocol PresentationDelegate {
        // MARK: - Properties

        /// The alert controllers currently presented by this
        /// delegate.
        var presentedAlertControllers: [UIAlertController] { get }

        // MARK: - Methods

        /// Presents the given alert controller.
        ///
        /// - Parameter alertController: The alert controller to
        ///   present.
        func present(_ alertController: UIAlertController)
    }
}
