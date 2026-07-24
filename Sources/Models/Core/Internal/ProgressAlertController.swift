//
//  ProgressAlertController.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

/// A `UIAlertController` that reports when presentation completes
/// and tolerates dismissal requests made before it appears.
///
/// Presentation delegates may defer or queue presentation, and
/// `UIViewController.dismiss(animated:completion:)` silently ignores
/// requests made before a controller is on screen. This subclass
/// records early dismissal requests and honors them as soon as the
/// alert finishes presenting. It also reports the moment of first
/// appearance, allowing work to be deferred until the alert is
/// visible.
final class ProgressAlertController: UIAlertController {
    // MARK: - Properties

    private var hasAppeared = false
    private var isPendingDismissal = false
    private var onDidAppearCallbacks = [@MainActor () -> Void]()

    // MARK: - View Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasAppeared = true

        let callbacks = onDidAppearCallbacks
        onDidAppearCallbacks.removeAll()
        callbacks.forEach { $0() }

        guard isPendingDismissal else { return }
        isPendingDismissal = false
        dismiss(animated: true)
    }

    // MARK: - Methods

    /// Dismisses the alert, deferring until presentation completes
    /// if it is not yet on screen.
    func dismissWhenPresented() {
        guard hasAppeared else {
            isPendingDismissal = true
            return
        }

        dismiss(animated: true)
    }

    /// Registers a callback that is invoked once the alert finishes
    /// presenting for the first time, or immediately if it already
    /// has. Callbacks are invoked in registration order.
    func onDidAppear(_ perform: @escaping @MainActor () -> Void) {
        guard !hasAppeared else { return perform() }
        onDidAppearCallbacks.append(perform)
    }
}
