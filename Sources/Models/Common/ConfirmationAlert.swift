//
//  ConfirmationAlert.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

/* Proprietary */
import Translator

public extension AlertKit {
    @MainActor
    final class ConfirmationAlert {
        // MARK: - Properties

        private let cancelButtonStyle: ActionStyle
        private let cancelButtonTitle: String
        private let confirmButtonStyle: ActionStyle
        private let confirmButtonTitle: String
        private let message: String
        private let title: String?

        private var messageAttributes: AttributedStringConfig?
        private var titleAttributes: AttributedStringConfig?

        // MARK: - Init

        public init(
            title: String? = nil,
            message: String,
            cancelButtonTitle: String = Constants.defaultCancelButtonTitle,
            cancelButtonStyle: ActionStyle = .cancel,
            confirmButtonTitle: String = Constants.defaultConfirmButtonTitle,
            confirmButtonStyle: ActionStyle = .preferred
        ) {
            self.cancelButtonTitle = cancelButtonTitle
            self.cancelButtonStyle = cancelButtonStyle
            self.confirmButtonTitle = confirmButtonTitle
            self.confirmButtonStyle = confirmButtonStyle
            self.message = message
            self.title = title
        }

        // MARK: - Enable/Disable Actions

        public func disableAction(at index: Int) {
            Alert.disableAction(at: index)
        }

        public func enableAction(at index: Int) {
            Alert.enableAction(at: index)
        }

        // MARK: - Set Attributed Strings

        public func setMessageAttributes(_ messageAttributes: AttributedStringConfig) {
            self.messageAttributes = messageAttributes
        }

        public func setTitleAttributes(_ titleAttributes: AttributedStringConfig) {
            self.titleAttributes = titleAttributes
        }

        // MARK: - Present

        public func present(
            translating keys: [TranslationOptionKey] = [
                .cancelButtonTitle,
                .confirmButtonTitle,
                .message,
                .title,
            ]
        ) async -> Bool {
            await AlertKit.presentWithTranslation(
                shouldTranslate: !keys.isEmpty,
                presentDirectly: {
                    await withCheckedContinuation { continuation in
                        present { continuation.resume(returning: $0) }
                    }
                },
                translate: { await translate(keys) },
                presentTranslated: { await $0.present(translating: []) },
                sender: self
            )
        }

        private func present(completion: @escaping (Bool) -> Void) {
            let alertController = UIAlertController(
                title: title?.sanitized,
                message: message.sanitized,
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(
                title: cancelButtonTitle.sanitized,
                style: cancelButtonStyle.uiAlertStyle
            ) { _ in
                completion(false)
            }

            let confirmAction = UIAlertAction(
                title: confirmButtonTitle.sanitized,
                style: confirmButtonStyle.uiAlertStyle
            ) { _ in
                completion(true)
            }

            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)

            if cancelButtonStyle == .preferred || cancelButtonStyle == .destructivePreferred {
                alertController.preferredAction = cancelAction
            } else if confirmButtonStyle == .preferred || confirmButtonStyle == .destructivePreferred {
                alertController.preferredAction = confirmAction
            }

            alertController.applyAttributedStrings(
                messageAttributes: messageAttributes,
                titleAttributes: titleAttributes
            )

            AlertKit.config.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<ConfirmationAlert, Error> {
            let uniqueKeys = keys.unique
            guard !uniqueKeys.isEmpty else { return .success(self) }

            let getTranslationsResult = await AlertKit.getTranslations(
                for: translationInputs(for: uniqueKeys)
            )

            switch getTranslationsResult {
            case let .success(translations):
                let alert: AKConfirmationAlert = .init(
                    title: title.map { translations.firstOutput(matching: $0) },
                    message: translations.firstOutput(matching: message),
                    cancelButtonTitle: translations.firstOutput(matching: cancelButtonTitle),
                    cancelButtonStyle: cancelButtonStyle,
                    confirmButtonTitle: translations.firstOutput(matching: confirmButtonTitle),
                    confirmButtonStyle: confirmButtonStyle
                )

                if let messageAttributes {
                    alert.setMessageAttributes(messageAttributes)
                }

                if let titleAttributes {
                    alert.setTitleAttributes(titleAttributes)
                }

                return .success(alert)

            case let .failure(error):
                return .failure(error)
            }
        }

        // MARK: - Translation Inputs

        private func translationInputs(for optionKeys: [TranslationOptionKey]) -> [TranslationInput] {
            var inputs = [TranslationInput]()
            for key in optionKeys {
                switch key {
                case .cancelButtonTitle:
                    inputs.append(.init(cancelButtonTitle))

                case .confirmButtonTitle:
                    inputs.append(.init(confirmButtonTitle))

                case .message:
                    inputs.append(.init(message))

                case .title:
                    guard let title else { continue }
                    inputs.append(.init(title))
                }
            }

            return inputs.nonDefaultUnique
        }
    }
}
