//
//  TextInputAlert.swift
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
    struct TextInputAlert: Equatable {
        // MARK: - Properties

        // String
        public let cancelButtonTitle: String
        public let confirmButtonTitle: String
        public let message: String
        public let title: String?

        // Other
        public let attributes: TextFieldAttributes
        public let confirmButtonStyle: ActionStyle

        // MARK: - Init

        public init(
            title: String? = nil,
            message: String,
            attributes: TextFieldAttributes = .init(),
            cancelButtonTitle: String = Constants.defaultCancelButtonTitle,
            confirmButtonTitle: String = Constants.defaultConfirmButtonTitle,
            confirmButtonStyle: ActionStyle = .preferred
        ) {
            self.title = title
            self.message = message
            self.attributes = attributes
            self.cancelButtonTitle = cancelButtonTitle
            self.confirmButtonTitle = confirmButtonTitle
            self.confirmButtonStyle = confirmButtonStyle
        }

        // MARK: - Present

        /// - Returns: On confirmation, the text entered into the text field.
        @MainActor
        public func present(translating keys: [TranslationOptionKey] = [.all]) async -> String? {
            guard !keys.isEmpty else {
                return await withCheckedContinuation { continuation in
                    present { string in
                        continuation.resume(returning: string)
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
        private func present(completion: @escaping (String?) -> Void) {
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            alertController.addTextField { $0.configure(with: attributes) }

            let cancelAction = UIAlertAction(
                title: cancelButtonTitle,
                style: .cancel
            ) { _ in
                completion(nil)
            }

            let confirmAction = UIAlertAction(
                title: confirmButtonTitle,
                style: confirmButtonStyle.uiAlertStyle
            ) { _ in
                completion(alertController.textFields?.first?.text)
            }

            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)

            if confirmButtonStyle == .preferred || confirmButtonStyle == .destructivePreferred {
                alertController.preferredAction = confirmAction
            }

            Config.shared.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<AKTextInputAlert, Error> {
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

                var attributes = attributes
                if let placeholderText = attributes.placeholderText {
                    attributes = attributes.replacingPlaceholderText(translations.firstOutput(matching: placeholderText))
                }

                if let sampleText = attributes.sampleText {
                    attributes = attributes.replacingSampleText(translations.firstOutput(matching: sampleText))
                }

                return .success(.init(
                    title: translatedTitle,
                    message: translations.firstOutput(matching: message),
                    attributes: attributes,
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
                case .all:
                    inputs.append(.init(cancelButtonTitle))
                    inputs.append(.init(confirmButtonTitle))
                    inputs.append(.init(message))

                    if let placeholderText = attributes.placeholderText {
                        inputs.append(.init(placeholderText))
                    }

                    if let sampleText = attributes.sampleText {
                        inputs.append(.init(sampleText))
                    }

                    guard let title else { continue }
                    inputs.append(.init(title))

                case .cancelButtonTitle:
                    inputs.append(.init(cancelButtonTitle))

                case .confirmButtonTitle:
                    inputs.append(.init(confirmButtonTitle))

                case .message:
                    inputs.append(.init(message))

                case .placeholderText:
                    guard let placeholderText = attributes.placeholderText else { continue }
                    inputs.append(.init(placeholderText))

                case .sampleText:
                    guard let sampleText = attributes.sampleText else { continue }
                    inputs.append(.init(sampleText))

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
