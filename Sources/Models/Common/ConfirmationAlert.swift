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
    final class ConfirmationAlert {
        // MARK: - Properties

        // ActionStyle
        public let cancelButtonStyle: ActionStyle
        public let confirmButtonStyle: ActionStyle

        // AttributedStringConfig
        private var messageAttributes: AttributedStringConfig?
        private var titleAttributes: AttributedStringConfig?

        // String
        public let cancelButtonTitle: String
        public let confirmButtonTitle: String
        public let message: String
        public let title: String?

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

        @MainActor
        public func disableAction(at index: Int) {
            Alert.disableAction(at: index)
        }

        @MainActor
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

        @MainActor
        public func present(
            translating keys: [TranslationOptionKey] = [
                .cancelButtonTitle,
                .confirmButtonTitle,
                .message,
                .title,
            ]
        ) async -> Bool {
            guard !keys.isEmpty else {
                return await withCheckedContinuation { continuation in
                    present { confirmed in
                        continuation.resume(returning: confirmed)
                    }
                }
            }

            let translateResult = await translate(keys)

            switch translateResult {
            case let .success(alert):
                return await alert.present(translating: [])

            case let .failure(error):
                Config.shared.loggerDelegate?.log(
                    error.localizedDescription,
                    metadata: [self, #file, #function, #line]
                )
                return await present(translating: [])
            }
        }

        @MainActor
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

            if let messageAttributes,
               let message = alertController.message {
                alertController.setValue(
                    message.attributed(messageAttributes),
                    forKey: Constants.uiAlertControllerAttributedMessageKeyName
                )
            }

            if let titleAttributes,
               let title = alertController.title {
                alertController.setValue(
                    title.attributed(titleAttributes),
                    forKey: Constants.uiAlertControllerAttributedTitleKeyName
                )
            }

            Config.shared.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<ConfirmationAlert, Error> {
            let translator = Config.shared.translationDelegate ?? TranslationService.shared

            var uniqueKeys = [TranslationOptionKey]()
            for key in keys where !uniqueKeys.contains(key) {
                uniqueKeys.append(key)
            }

            guard !uniqueKeys.isEmpty else { return .success(self) }

            let getTranslationsResult = await translator.getTranslations(
                translationInputs(for: uniqueKeys),
                languagePair: .init(
                    from: Config.shared.sourceLanguageCode,
                    to: Config.shared.targetLanguageCode
                ),
                hud: Config.shared.translationHUDConfig,
                timeout: Config.shared.translationTimeoutConfig
            )

            switch getTranslationsResult {
            case let .success(translations):
                var translatedTitle: String?
                if let title {
                    translatedTitle = translations.firstOutput(matching: title)
                }

                let alert: AKConfirmationAlert = .init(
                    title: translatedTitle,
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
                return .failure(.translationFailed(error.localizedDescription))
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

            var uniqueInputs = [TranslationInput]()
            for input in inputs where !uniqueInputs.contains(input) {
                uniqueInputs.append(input)
            }

            return uniqueInputs.filter { $0.value != Constants.defaultActionTitle }
        }
    }
}
