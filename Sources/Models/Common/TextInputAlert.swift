//
//  TextInputAlert.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

/* Proprietary */
import Translator

private var _onTextFieldChange: ((UITextField?) -> Void)?

public extension AlertKit {
    final class TextInputAlert {
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

        // TextFieldAttributes
        public let attributes: TextFieldAttributes

        private weak var observedAlertControllerWindow: UIWindow?
        private weak var observedTextField: UITextField?

        // MARK: - Object Lifecycle

        public init(
            title: String? = nil,
            message: String,
            attributes: TextFieldAttributes = .init(),
            cancelButtonTitle: String = Constants.defaultCancelButtonTitle,
            cancelButtonStyle: ActionStyle = .cancel,
            confirmButtonTitle: String = Constants.defaultConfirmButtonTitle,
            confirmButtonStyle: ActionStyle = .preferred
        ) {
            self.title = title
            self.message = message
            self.attributes = attributes
            self.cancelButtonTitle = cancelButtonTitle
            self.cancelButtonStyle = cancelButtonStyle
            self.confirmButtonTitle = confirmButtonTitle
            self.confirmButtonStyle = confirmButtonStyle
        }

        deinit {
            removeTextFieldChangeObserver()
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

        // MARK: - On Text Field Change

        public func onTextFieldChange(_ perform: @escaping (UITextField?) -> Void) {
            _onTextFieldChange = perform
        }

        private func removeTextFieldChangeObserver() {
            NotificationCenter.default.removeObserver(
                self,
                name: UIWindow.didBecomeHiddenNotification,
                object: observedAlertControllerWindow
            )

            NotificationCenter.default.removeObserver(
                self,
                name: UITextField.textDidChangeNotification,
                object: observedTextField
            )

            observedAlertControllerWindow = nil
            observedTextField = nil
            _onTextFieldChange = nil
        }

        // MARK: - Set Attributed Strings

        public func setMessageAttributes(_ messageAttributes: AttributedStringConfig) {
            self.messageAttributes = messageAttributes
        }

        public func setTitleAttributes(_ titleAttributes: AttributedStringConfig) {
            self.titleAttributes = titleAttributes
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
                    sender: self,
                    fileName: #fileID,
                    function: #function,
                    line: #line
                )
                return await present(translating: [])
            }
        }

        @MainActor
        private func present(completion: @escaping (String?) -> Void) {
            let alertController = UIAlertController(
                title: title?.sanitized,
                message: message.sanitized,
                preferredStyle: .alert
            )

            alertController.addTextField { $0.configure(with: self.attributes) }

            let cancelAction = UIAlertAction(
                title: cancelButtonTitle.sanitized,
                style: cancelButtonStyle.uiAlertStyle
            ) { _ in
                completion(nil)
            }

            let confirmAction = UIAlertAction(
                title: confirmButtonTitle.sanitized,
                style: confirmButtonStyle.uiAlertStyle
            ) { _ in
                completion(alertController.textFields?.first?.text)
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

            if let onTextFieldChange = _onTextFieldChange {
                observedAlertControllerWindow = alertController.view.window
                observedTextField = alertController.textFields?.first

                NotificationCenter.default.addObserver(
                    forName: UIWindow.didBecomeHiddenNotification,
                    object: observedAlertControllerWindow,
                    queue: .main
                ) { [weak self] _ in // FIXME: Possible retain cycle here.
                    self?.removeTextFieldChangeObserver()
                }

                NotificationCenter.default.addObserver(
                    forName: UITextField.textDidChangeNotification,
                    object: observedTextField,
                    queue: .main
                ) { _ in
                    onTextFieldChange(alertController.textFields?.first)
                }
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
