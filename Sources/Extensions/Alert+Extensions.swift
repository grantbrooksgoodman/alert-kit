//
//  Alert+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

@MainActor
extension AlertKit.Alert {
    // MARK: - Properties

    private static var presentedAlertControllers: [UIAlertController] { AlertKit.config.presentationDelegate?.presentedAlertControllers ?? [] }

    // MARK: - Methods

    static func enableAction(at index: Int) {
        presentedAlertControllers.forEach { $0.actions.itemAt(index)?.isEnabled = true }
    }

    static func disableAction(at index: Int) {
        presentedAlertControllers.forEach { $0.actions.itemAt(index)?.isEnabled = false }
    }
}

extension UIAlertController {
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
