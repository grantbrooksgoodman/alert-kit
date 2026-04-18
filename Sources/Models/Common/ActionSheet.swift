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
                .cancelButtonTitle,
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
            var alertController = UIAlertController(
                title: title?.sanitized,
                message: message?.sanitized,
                preferredStyle: .actionSheet
            )

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
