//
//  Alert.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

public extension AlertKit {
    struct Alert: Equatable {
        // MARK: - Properties

        // Array
        public let actions: [AKAction]

        // String
        public let message: String
        public let title: String?

        // MARK: - Init

        public init(
            title: String? = nil,
            message: String,
            actions: [AKAction] = [.init("OK", style: .cancel, effect: {})]
        ) {
            assert(!actions.isEmpty, "Modal alerts are not supported")
            self.title = title
            self.message = message
            self.actions = actions
        }

        // MARK: - Present

        @MainActor
        public func present(translating keys: [TranslationOptionKey] = [.all]) async {
            guard !keys.isEmpty else {
                return await withCheckedContinuation { continuation in
                    present { continuation.resume() }
                }
            }

            let translateResult = await translate(keys)

            switch translateResult {
            case let .success(alert):
                return await alert.present(translating: [])

            case let .failure(error):
                print(error.localizedDescription)
                return await present(translating: [])
            }
        }

        @MainActor
        private func present(completion: @escaping () -> Void) {
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            for action in actions {
                let alertAction = UIAlertAction(
                    title: action.title,
                    style: action.style.uiAlertStyle
                ) { _ in
                    action.perform()
                    completion()
                }

                alertAction.isEnabled = action.isEnabled
                alertController.addAction(alertAction)

                if action.style == .preferred || action.style == .destructivePreferred {
                    alertController.preferredAction = alertAction
                }
            }

            Config.shared.presentationDelegate?.present(alertController)
        }
    }
}
