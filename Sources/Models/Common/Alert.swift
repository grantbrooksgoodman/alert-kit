//
//  Alert.swift
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
    /// An alert that displays a title, message, and a set of actions.
    ///
    /// Use `Alert` to present a standard alert dialog to the user using
    /// your app. Create an alert with a title, an optional message, and
    /// one or more actions, then call ``present(translating:)`` to display
    /// it:
    ///
    /// ```swift
    /// let alert = AKAlert(
    ///     title: "Remove Item",
    ///     message: "This action cannot be undone.",
    ///     actions: [
    ///         .init("Remove", style: .destructive) {
    ///             removeItem()
    ///         },
    ///         .init("Cancel", style: .cancel) {},
    ///     ]
    /// )
    ///
    /// await alert.present()
    /// ```
    ///
    /// When you omit the `actions` parameter, the alert displays a single
    /// "OK" button with the ``ActionStyle/cancel`` style.
    ///
    /// ## Translation
    ///
    /// By default, ``present(translating:)`` translates the alert's title,
    /// message, and action titles into the configured target language
    /// before presentation. To present without translation, pass an empty
    /// array:
    ///
    /// ```swift
    /// await alert.present(translating: [])
    /// ```
    ///
    /// To translate only specific parts of the alert, provide the
    /// corresponding ``TranslationOptionKey`` values:
    ///
    /// ```swift
    /// await alert.present(translating: [.title, .message])
    /// ```
    ///
    /// - Important: The `actions` array must contain at least one action.
    ///   Passing an empty array triggers a runtime assertion failure.
    @MainActor
    final class Alert {
        // MARK: - Properties

        private let actions: [Action]
        private let message: String?
        private let title: String?

        private var messageAttributes: AttributedStringConfig?
        private var titleAttributes: AttributedStringConfig?

        // MARK: - Init

        /// Creates an alert with the specified title, message, and actions.
        ///
        /// - Parameters:
        ///   - title: The title of the alert. The default is `nil`.
        ///   - message: The descriptive message of the alert.
        ///   - actions: The actions to display as buttons in the alert.
        ///     The default is a single "OK" button with the
        ///     ``ActionStyle/cancel`` style.
        public init(
            title: String? = nil,
            message: String?,
            actions: [Action] = [.init(Constants.defaultActionTitle, style: .cancel, effect: {})]
        ) {
            assert(!actions.isEmpty, "Modal alerts are not supported")
            self.title = title
            self.message = message
            self.actions = actions
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

        /// Presents the alert and suspends until the user selects an
        /// action.
        ///
        /// This method translates the alert's content before presentation
        /// according to the specified keys. Each key identifies a part of
        /// the alert to translate. To skip translation, pass an empty
        /// array.
        ///
        /// - Parameter keys: The parts of the alert to translate. The
        ///   default includes all translatable content.
        public func present(
            translating keys: [TranslationOptionKey] = [
                .actions(),
                .message,
                .title,
            ]
        ) async {
            await AlertKit.presentWithTranslation(
                shouldTranslate: !keys.isEmpty,
                presentDirectly: {
                    await withCheckedContinuation { continuation in
                        let continuation = ContinuationGuard(
                            continuation,
                            fallbackValue: ()
                        )

                        present { continuation.resume(returning: ()) }
                    }
                },
                translate: { await translate(keys) },
                presentTranslated: { await $0.present(translating: []) },
                sender: self
            )
        }

        private func present(completion: @escaping () -> Void) {
            let alertController = UIAlertController(
                title: title?.sanitized,
                message: message?.sanitized,
                preferredStyle: .alert
            )

            alertController.addActions(
                actions,
                completion: completion
            )

            alertController.applyAttributedStrings(
                messageAttributes: messageAttributes,
                titleAttributes: titleAttributes
            )

            AlertKit.config.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<Alert, Error> {
            let uniqueKeys = keys.unique
            guard !uniqueKeys.isEmpty else { return .success(self) }

            let getTranslationsResult = await AlertKit.getTranslations(
                for: translationInputs(for: uniqueKeys)
            )

            switch getTranslationsResult {
            case let .success(translations):
                let alert: AKAlert = .init(
                    title: title.map { translations.firstOutput(matching: $0) },
                    message: message.map { translations.firstOutput(matching: $0) },
                    actions: actions.applying(translations)
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
                case let .actions(actions):
                    guard !actions.isEmpty else {
                        inputs.append(
                            contentsOf: self.actions.map { .init($0.title) }
                        )
                        continue
                    }

                    inputs.append(
                        contentsOf: self.actions.filter {
                            actions.contains($0)
                        }.map { .init($0.title) }
                    )

                case .message:
                    guard let message else { continue }
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
