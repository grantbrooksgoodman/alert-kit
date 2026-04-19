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
    /// An alert that asks the user to confirm or cancel an action.
    ///
    /// Use `ConfirmationAlert` to present a simple two-button dialog that
    /// resolves to a Boolean result. The confirm button indicates the
    /// affirmative choice, and the cancel button dismisses the alert
    /// without action:
    ///
    /// ```swift
    /// let confirmed = await AKConfirmationAlert(
    ///     title: "Remove Item",
    ///     message: "This action cannot be undone."
    /// ).present()
    ///
    /// if confirmed {
    ///     removeItem()
    /// }
    /// ```
    ///
    /// You can customize the button titles and styles:
    ///
    /// ```swift
    /// let alert = AKConfirmationAlert(
    ///     message: "Discard your changes?",
    ///     cancelButtonTitle: "Keep Editing",
    ///     confirmButtonTitle: "Discard",
    ///     confirmButtonStyle: .destructive
    /// )
    ///
    /// if await alert.present() {
    ///     discardChanges()
    /// }
    /// ```
    ///
    /// By default, ``present(translating:)`` translates all content into
    /// the configured target language. Pass an empty array to skip
    /// translation.
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

        /// Creates a confirmation alert with the specified title, message,
        /// and button configuration.
        ///
        /// - Parameters:
        ///   - title: The title of the alert. The default is `nil`.
        ///   - message: The descriptive message of the alert.
        ///   - cancelButtonTitle: The title of the cancel button. The
        ///     default is "Cancel".
        ///   - cancelButtonStyle: The style of the cancel button. The
        ///     default is ``ActionStyle/cancel``.
        ///   - confirmButtonTitle: The title of the confirm button. The
        ///     default is "Confirm".
        ///   - confirmButtonStyle: The style of the confirm button. The
        ///     default is ``ActionStyle/preferred``.
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

        /// Disables the action at the specified index in any currently
        /// presented alert controller.
        ///
        /// - Parameter index: The zero-based index of the action to
        ///   disable.
        public func disableAction(at index: Int) {
            Alert.disableAction(at: index)
        }

        /// Enables the action at the specified index in any currently
        /// presented alert controller.
        ///
        /// - Parameter index: The zero-based index of the action to
        ///   enable.
        public func enableAction(at index: Int) {
            Alert.enableAction(at: index)
        }

        // MARK: - Set Attributed Strings

        /// Sets the attributed string configuration for the alert's
        /// message.
        ///
        /// Call this method before ``present(translating:)`` to customize
        /// the appearance of the message text.
        ///
        /// - Parameter messageAttributes: The attributed string
        ///   configuration to apply to the message.
        public func setMessageAttributes(_ messageAttributes: AttributedStringConfig) {
            self.messageAttributes = messageAttributes
        }

        /// Sets the attributed string configuration for the alert's
        /// title.
        ///
        /// Call this method before ``present(translating:)`` to customize
        /// the appearance of the title text.
        ///
        /// - Parameter titleAttributes: The attributed string
        ///   configuration to apply to the title.
        public func setTitleAttributes(_ titleAttributes: AttributedStringConfig) {
            self.titleAttributes = titleAttributes
        }

        // MARK: - Present

        /// Presents the alert and suspends until the user makes a
        /// choice.
        ///
        /// This method translates the alert's content before presentation
        /// according to the specified keys. Each key identifies a part of
        /// the alert to translate. To skip translation, pass an empty
        /// array.
        ///
        /// - Parameter keys: The parts of the alert to translate. The
        ///   default includes all translatable content.
        ///
        /// - Returns: `true` if the user taps the confirm button;
        ///   `false` if they tap the cancel button.
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
                        let continuation = ContinuationGuard(
                            continuation,
                            fallbackValue: false
                        )

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
