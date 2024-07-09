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
    final class TextInputAlert {
        // MARK: - Properties

        // NSAttributedString
        private var attributedMessage: NSAttributedString?
        private var attributedTitle: NSAttributedString?

        // String
        private let cancelButtonTitle: String
        private let confirmButtonTitle: String
        private let message: String
        private let title: String?

        // Other
        private let attributes: TextFieldAttributes
        private let confirmButtonStyle: ActionStyle

        // MARK: - Object Lifecycle

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

        deinit {
            NotificationCenter.default.removeObserver(
                self,
                name: UITextField.textDidChangeNotification,
                object: nil
            )
        }

        // MARK: - On Text Field Change

        public func onTextFieldChange(_ perform: @escaping (UITextField?) -> Void) {
            NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                let alertController = (Config.shared.presentationDelegate?.keyViewController as? UIAlertController)
                perform(alertController?.textFields?.first)
            }
        }

        // MARK: - Set Attributed Strings

        public func setAttributedMessage(_ attributedMessage: NSAttributedString) {
            self.attributedMessage = attributedMessage
        }

        public func setAttributedTitle(_ attributedTitle: NSAttributedString) {
            self.attributedTitle = attributedTitle
        }

        // MARK: - Present

        /// - Returns: On confirmation, the text entered into the text field.
        @MainActor
        public func present(
            translating keys: [TranslationOptionKey] = [
                .cancelButtonTitle,
                .confirmButtonTitle,
                .message,
                .placeholderText,
                .sampleText,
                .title,
            ]
        ) async -> String? {
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

            alertController.addTextField { $0.configure(with: self.attributes) }

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

            if let attributedMessage {
                alertController.setValue(attributedMessage, forKey: Constants.uiAlertControllerAttributedMessageKeyName)
            }

            if let attributedTitle {
                alertController.setValue(attributedTitle, forKey: Constants.uiAlertControllerAttributedTitleKeyName)
            }

            Config.shared.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<TextInputAlert, Error> {
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

                let alert: AKTextInputAlert = .init(
                    title: translatedTitle,
                    message: translations.firstOutput(matching: message),
                    attributes: attributes,
                    cancelButtonTitle: translations.firstOutput(matching: cancelButtonTitle),
                    confirmButtonTitle: translations.firstOutput(matching: confirmButtonTitle),
                    confirmButtonStyle: confirmButtonStyle
                )

                if let attributedMessage {
                    let translatedAttributedMessage = translations.firstOutput(matching: attributedMessage.string)
                    if translatedAttributedMessage == attributedMessage.string {
                        alert.setAttributedMessage(attributedMessage)
                    } else {
                        alert.setAttributedMessage(.init(
                            string: translatedAttributedMessage,
                            attributes: attributedMessage.attributes(at: 0, effectiveRange: nil)
                        ))
                    }
                }

                if let attributedTitle {
                    let translatedAttributedTitle = translations.firstOutput(matching: attributedTitle.string)
                    if translatedAttributedTitle == attributedTitle.string {
                        alert.setAttributedTitle(attributedTitle)
                    } else {
                        alert.setAttributedTitle(.init(
                            string: translatedAttributedTitle,
                            attributes: attributedTitle.attributes(at: 0, effectiveRange: nil)
                        ))
                    }
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
                    guard let attributedMessage else {
                        inputs.append(.init(message))
                        continue
                    }

                    inputs.append(.init(attributedMessage.string))

                case .placeholderText:
                    guard let placeholderText = attributes.placeholderText else { continue }
                    inputs.append(.init(placeholderText))

                case .sampleText:
                    guard let sampleText = attributes.sampleText else { continue }
                    inputs.append(.init(sampleText))

                case .title:
                    guard let attributedTitle else {
                        guard let title else { continue }
                        inputs.append(.init(title))
                        continue
                    }

                    inputs.append(.init(attributedTitle.string))
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
