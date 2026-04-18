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

public extension AlertKit {
    @MainActor
    final class TextInputAlert {
        // MARK: - Properties

        private let attributes: TextFieldAttributes
        private let cancelButtonStyle: ActionStyle
        private let cancelButtonTitle: String
        private let confirmButtonStyle: ActionStyle
        private let confirmButtonTitle: String
        private let message: String
        private let title: String?

        private var messageAttributes: AttributedStringConfig?
        private var textDidChangeObserver: NSObjectProtocol?
        private var titleAttributes: AttributedStringConfig?
        private var windowDidBecomeHiddenObserver: NSObjectProtocol?
        private var _onTextFieldChange: (@MainActor (UITextField?) -> Void)?

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

        @MainActor
        deinit {
            removeTextFieldChangeObserver()
        }

        // MARK: - Enable/Disable Actions

        public func disableAction(at index: Int) {
            Alert.disableAction(at: index)
        }

        public func enableAction(at index: Int) {
            Alert.enableAction(at: index)
        }

        // MARK: - On Text Field Change

        public func onTextFieldChange(
            _ perform: @escaping @MainActor (UITextField?) -> Void
        ) {
            _onTextFieldChange = perform
        }

        private func removeTextFieldChangeObserver() {
            if let windowDidBecomeHiddenObserver {
                NotificationCenter.default.removeObserver(windowDidBecomeHiddenObserver)
                self.windowDidBecomeHiddenObserver = nil
            }

            if let textDidChangeObserver {
                NotificationCenter.default.removeObserver(textDidChangeObserver)
                self.textDidChangeObserver = nil
            }

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

            alertController.applyAttributedStrings(
                messageAttributes: messageAttributes,
                titleAttributes: titleAttributes
            )

            AlertKit.config.presentationDelegate?.present(alertController)
            guard let onTextFieldChange = _onTextFieldChange else { return }

            observedTextField = alertController.textFields?.first
            textDidChangeObserver = NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: observedTextField,
                queue: .main
            ) { [weak alertController] _ in
                Task { @MainActor in
                    onTextFieldChange(alertController?.textFields?.first)
                }
            }

            DispatchQueue.main.async { [weak alertController, weak self] in
                guard let self,
                      let window = alertController?.view.window else { return }

                observedAlertControllerWindow = window
                windowDidBecomeHiddenObserver = NotificationCenter.default.addObserver(
                    forName: UIWindow.didBecomeHiddenNotification,
                    object: window,
                    queue: .main
                ) { [weak self] _ in
                    Task { @MainActor in
                        self?.removeTextFieldChangeObserver()
                    }
                }
            }
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<TextInputAlert, Error> {
            let uniqueKeys = keys.unique
            guard !uniqueKeys.isEmpty else { return .success(self) }

            let getTranslationsResult = await AlertKit.getTranslations(
                for: translationInputs(for: uniqueKeys)
            )

            switch getTranslationsResult {
            case let .success(translations):
                var attributes = attributes
                if let placeholderText = attributes.placeholderText {
                    attributes = attributes.replacingPlaceholderText(translations.firstOutput(matching: placeholderText))
                }

                if let sampleText = attributes.sampleText {
                    attributes = attributes.replacingSampleText(translations.firstOutput(matching: sampleText))
                }

                let alert: AKTextInputAlert = .init(
                    title: title.map { translations.firstOutput(matching: $0) },
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

                if let onTextFieldChange = _onTextFieldChange {
                    alert.onTextFieldChange(onTextFieldChange)
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

            return inputs.nonDefaultUnique
        }
    }
}
