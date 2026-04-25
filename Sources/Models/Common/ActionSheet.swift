//
//  ActionSheet.swift
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
    /// An action sheet that displays a title, message, and a list of
    /// actions.
    ///
    /// Use `ActionSheet` to present a set of choices related to an action
    /// the user initiates. Create an action sheet with the actions you
    /// want to offer, then call ``present(translating:)`` to display it:
    ///
    /// ```swift
    /// let actionSheet = AKActionSheet(
    ///     title: "Share Photo",
    ///     actions: [
    ///         .init("Save to Camera Roll") {
    ///             savePhoto()
    ///         },
    ///         .init("Copy Link") {
    ///             copyLink()
    ///         },
    ///     ]
    /// )
    ///
    /// await actionSheet.present()
    /// ```
    ///
    /// A cancel button is added automatically unless one of the provided
    /// actions uses the ``ActionStyle/cancel`` style. You can customize
    /// the cancel button's title through the `cancelButtonTitle`
    /// parameter.
    ///
    /// On iOS 26 and later, the action sheet may be presented as a
    /// popover. Provide a ``SourceItem`` to specify the view that the
    /// popover anchors to.
    ///
    /// By default, ``present(translating:)`` translates all content into
    /// the configured target language. Pass an empty array to skip
    /// translation.
    ///
    /// - Important: The `actions` array must contain at least one action.
    ///   Passing an empty array triggers a runtime assertion failure.
    @MainActor
    final class ActionSheet {
        // MARK: - Properties

        private let actions: [Action]
        private let cancelButtonTitle: String
        private let message: String?
        private let sourceItem: SourceItem?
        private let title: String?

        private var messageAttributes: AttributedStringConfig?
        private var titleAttributes: AttributedStringConfig?

        // MARK: - Computed Properties

        private var sourceItemView: UIView? {
            guard let inspectionDelegate = AlertKit.config.inspectionDelegate,
                  let sourceItem else { return nil }

            switch sourceItem {
            case let .custom(customSourceItem):
                switch customSourceItem {
                case let .string(string): return inspectionDelegate.sourceItem(string.hashValue)
                case let .view(view): return view
                }

            case .message:
                guard let message else { return nil }
                return inspectionDelegate.sourceItem(message.hashValue)

            case .title:
                guard let title else { return nil }
                return inspectionDelegate.sourceItem(title.hashValue)
            }
        }

        // MARK: - Init

        /// Creates an action sheet with the specified title, message,
        /// actions, cancel button title, and source item.
        ///
        /// - Parameters:
        ///   - title: The title of the action sheet. The default is `nil`.
        ///   - message: The descriptive message of the action sheet. The
        ///     default is `nil`.
        ///   - actions: The actions to display in the action sheet.
        ///   - cancelButtonTitle: The title of the cancel button. The
        ///     default is "Cancel". This button is added automatically
        ///     unless one of the provided actions uses the
        ///     ``ActionStyle/cancel`` style.
        ///   - sourceItem: The element that the action sheet's popover
        ///     anchors to on iOS 26 and later. The default is `nil`.
        public init(
            title: String? = nil,
            message: String? = nil,
            actions: [Action],
            cancelButtonTitle: String = Constants.defaultCancelButtonTitle,
            sourceItem: SourceItem? = nil
        ) {
            assert(!actions.isEmpty, "Modal alerts are not supported")
            self.title = title
            self.message = message
            self.actions = actions
            self.cancelButtonTitle = cancelButtonTitle
            self.sourceItem = sourceItem
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

        /// Sets the attributed string configuration for the action
        /// sheet's message.
        ///
        /// Call this method before ``present(translating:)`` to customize
        /// the appearance of the message text.
        ///
        /// - Parameter messageAttributes: The attributed string
        ///   configuration to apply to the message.
        public func setMessageAttributes(_ messageAttributes: AttributedStringConfig) {
            self.messageAttributes = messageAttributes
        }

        /// Sets the attributed string configuration for the action
        /// sheet's title.
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

        /// Presents the action sheet and suspends until the user
        /// selects an action or cancels.
        ///
        /// This method translates the action sheet's content before
        /// presentation according to the specified keys. Each key
        /// identifies a part of the action sheet to translate. To skip
        /// translation, pass an empty array.
        ///
        /// - Parameter keys: The parts of the action sheet to translate.
        ///   The default includes all translatable content.
        public func present(
            translating keys: [TranslationOptionKey] = [
                .actions(),
                .cancelButtonTitle,
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
            var alertController = UIAlertController(
                title: title?.sanitized,
                message: message?.sanitized,
                preferredStyle: .actionSheet
            )

            // When the action sheet has a title but no message, promote
            // the title into the message position. UIAlertController
            // renders messages with a smaller, lighter font that
            // produces a more natural layout for title-only action sheets.
            if message == nil,
               let title {
                alertController = .init(
                    title: nil,
                    message: title.sanitized,
                    preferredStyle: .actionSheet
                )
            }

            alertController.addActions(
                actions,
                completion: completion
            )

            if !actions.contains(where: { $0.style == .cancel }) {
                let cancelAction = UIAlertAction(
                    title: cancelButtonTitle.sanitized,
                    style: .cancel
                ) { _ in
                    completion()
                }
                alertController.addAction(cancelAction)
            }

            alertController.applyAttributedStrings(
                messageAttributes: messageAttributes,
                titleAttributes: titleAttributes
            )

            alertController.popoverPresentationController?.sourceItem = sourceItemView
            AlertKit.config.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<ActionSheet, Error> {
            let uniqueKeys = keys.unique
            guard !uniqueKeys.isEmpty else { return .success(self) }

            let result = await AlertKit.getTranslations(for: translationInputs(for: uniqueKeys))

            switch result {
            case let .success(translations):
                let alert: AKActionSheet = .init(
                    title: title.map { translations.firstOutput(matching: $0) },
                    message: message.map { translations.firstOutput(matching: $0) },
                    actions: actions.applying(translations),
                    cancelButtonTitle: translations.firstOutput(matching: cancelButtonTitle),
                    sourceItem: sourceItem
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

                case .cancelButtonTitle:
                    inputs.append(.init(cancelButtonTitle))

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
