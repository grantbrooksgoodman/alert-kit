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
    @MainActor
    final class Alert {
        // MARK: - Properties

        private let actions: [Action]
        private let message: String?
        private let title: String?

        private var messageAttributes: AttributedStringConfig?
        private var titleAttributes: AttributedStringConfig?

        // MARK: - Init

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
                .actions(),
                .message,
                .title,
            ]
        ) async {
            await AlertKit.presentWithTranslation(
                shouldTranslate: !keys.isEmpty,
                presentDirectly: {
                    await withCheckedContinuation { continuation in
                        present { continuation.resume() }
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
