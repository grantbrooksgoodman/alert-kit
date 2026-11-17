//
//  UIAlertController+InternalExtensions.swift
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
        @MainActor
        static let bottomInset: CGFloat = UIApplication.isV26Compatible ? 34 : 26

        /// The distance between the progress view and the bottom edge
        /// of the alert when a cancel action is present, accounting
        /// for the height of the action row.
        @MainActor
        static let bottomInsetWithCancelAction: CGFloat = UIApplication.isV26Compatible ? 78 : 62

        /// The distance between the progress view and the leading and
        /// trailing edges of the alert.
        static let horizontalInset: CGFloat = 30

        /// The whitespace appended to the alert's message to reserve
        /// vertical space for the progress view.
        static let messagePadding = "\n\n"

        /// The whitespace appended to the alert's message when a cancel
        /// action is present to reserve vertical space for the progress view.
        static let messagePaddingWithCancelAction = "\n"
    }

    // MARK: - Methods

    func addActions(
        _ actions: [AlertKit.Action],
        completion: @escaping () -> Void
    ) {
        for action in actions {
            let alertAction = UIAlertAction(
                title: action.title.sanitized,
                style: action.style.uiAlertStyle
            ) { _ in
                action.perform()
                completion()
            }

            alertAction.isEnabled = action.isEnabled
            addAction(alertAction)

            if action.style == .preferred ||
                action.style == .destructivePreferred {
                preferredAction = alertAction
            }
        }
    }

    func addProgressView(
        hasCancelAction: Bool
    ) -> UIProgressView {
        // `UIAlertController` provides no supported API for embedding
        // accessory views. Trailing newlines appended to the message
        // reserve vertical space beneath the text, and the progress
        // view is pinned into that space relative to the alert's
        // bottom edge. The insets below are tuned to the current
        // alert layout metrics and should be verified against new
        // major OS releases.
        message = [
            message,
            hasCancelAction ? ProgressViewMetrics.messagePaddingWithCancelAction : ProgressViewMetrics.messagePadding,
        ].compactMap(\.self).joined()

        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -(hasCancelAction ? ProgressViewMetrics.bottomInsetWithCancelAction : ProgressViewMetrics.bottomInset)
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

    func applyAttributedStrings(
        messageAttributes: AlertKit.AttributedStringConfig?,
        titleAttributes: AlertKit.AttributedStringConfig?
    ) {
        if let messageAttributes,
           let message {
            setValue(
                message.attributed(messageAttributes),
                forKey: AlertKit.Constants.uiAlertControllerAttributedMessageKeyName
            )
        }

        if let titleAttributes,
           let title {
            setValue(
                title.attributed(titleAttributes),
                forKey: AlertKit.Constants.uiAlertControllerAttributedTitleKeyName
            )
        }
    }
}
