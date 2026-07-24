//
//  ProgressAlert+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

extension UIAlertController {
    // MARK: - Types

    private enum ProgressViewMetrics {
        /// The distance between the progress view and the bottom edge
        /// of the alert when no cancel action is present.
        static let bottomInset: CGFloat = 34

        /// The distance between the progress view and the bottom edge
        /// of the alert when a cancel action is present, accounting
        /// for the height of the action row.
        static let bottomInsetWithCancelAction: CGFloat = 78

        /// The distance between the progress view and the leading and
        /// trailing edges of the alert.
        static let horizontalInset: CGFloat = 16

        /// The whitespace appended to the alert's message to reserve
        /// vertical space for the progress view.
        static let messagePadding = "\n\n"
    }

    // MARK: - Methods

    func addProgressView(hasCancelAction: Bool) -> UIProgressView {
        // `UIAlertController` provides no supported API for embedding
        // accessory views. Trailing newlines appended to the message
        // reserve vertical space beneath the text, and the progress
        // view is pinned into that space relative to the alert's
        // bottom edge. The insets below are tuned to the current
        // alert layout metrics and should be verified against new
        // major OS releases.
        message = [
            message,
            ProgressViewMetrics.messagePadding,
        ].compactMap(\.self).joined()

        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        let bottomInset = hasCancelAction
            ? ProgressViewMetrics.bottomInsetWithCancelAction
            : ProgressViewMetrics.bottomInset

        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -bottomInset
            ),
            progressView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: ProgressViewMetrics.horizontalInset
            ),
            progressView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -ProgressViewMetrics.horizontalInset
            ),
        ])

        return progressView
    }
}
