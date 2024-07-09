//
//  ConfirmationAlert.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

/* 3rd-party */
import Translator

public extension AlertKit {
    struct ConfirmationAlert: Equatable {
        // MARK: - Properties

        // ActionStyle
        public let confirmButtonStyle: ActionStyle

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
            confirmButtonTitle: String = Constants.defaultConfirmButtonTitle,
            confirmButtonStyle: ActionStyle = .preferred
        ) {
            self.cancelButtonTitle = cancelButtonTitle
            self.confirmButtonTitle = confirmButtonTitle
            self.confirmButtonStyle = confirmButtonStyle
            self.message = message
            self.title = title
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
                title: title,
                message: message,
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(
                title: cancelButtonTitle,
                style: .cancel
            ) { _ in
                completion(false)
            }

            let confirmAction = UIAlertAction(
                title: confirmButtonTitle,
                style: confirmButtonStyle.uiAlertStyle
            ) { _ in
                completion(true)
            }

            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)

            if confirmButtonStyle == .preferred || confirmButtonStyle == .destructivePreferred {
                alertController.preferredAction = confirmAction
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
                if let title = title {
                    translatedTitle = translations.firstOutput(matching: title)
                }

                return .success(.init(
                    title: translatedTitle,
                    message: translations.firstOutput(matching: message),
                    cancelButtonTitle: translations.firstOutput(matching: cancelButtonTitle),
                    confirmButtonTitle: translations.firstOutput(matching: confirmButtonTitle),
                    confirmButtonStyle: confirmButtonStyle
                ))

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
