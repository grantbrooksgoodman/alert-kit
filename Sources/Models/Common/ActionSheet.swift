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
    final class ActionSheet {
        // MARK: - Properties

        public let actions: [Action]
        public let cancelButtonTitle: String
        public let message: String?
        public let sourceItem: SourceItem?
        public let title: String?

        private var messageAttributes: AttributedStringConfig?
        private var titleAttributes: AttributedStringConfig?

        // MARK: - Computed Properties

        private var sourceItemView: UIView? {
            guard let inspectionDelegate = Config.shared.inspectionDelegate,
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

        @MainActor
        public func disableAction(at index: Int) {
            Alert.disableAction(at: index)
        }

        @MainActor
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

        @MainActor
        public func present(
            translating keys: [TranslationOptionKey] = [
                .actions(),
                .cancelButtonTitle,
                .message,
                .title,
            ]
        ) async {
            guard !keys.isEmpty else {
                return await withCheckedContinuation { continuation in
                    present { continuation.resume() }
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

            for action in actions {
                let alertAction = UIAlertAction(
                    title: action.title.sanitized,
                    style: action.style.uiAlertStyle
                ) { _ in
                    action.perform()
                    completion()
                }

                alertAction.isEnabled = action.isEnabled
                alertController.addAction(alertAction)

                if action.style == .preferred || action.style == .destructivePreferred {
                    alertController.preferredAction = alertAction
                }
            }

            if !actions.contains(where: { $0.style == .cancel }) {
                let cancelAction = UIAlertAction(
                    title: cancelButtonTitle.sanitized,
                    style: .cancel
                ) { _ in
                    completion()
                }
                alertController.addAction(cancelAction)
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

            alertController.popoverPresentationController?.sourceItem = sourceItemView
            Config.shared.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<ActionSheet, Error> {
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
                var actions = [Action]()
                for action in self.actions {
                    actions.append(.init(
                        translations.firstOutput(matching: action.title),
                        isEnabled: action.isEnabled,
                        style: action.style,
                        effect: action.effect
                    ))
                }

                var translatedMessage: String?
                if let message = message {
                    translatedMessage = translations.firstOutput(matching: message)
                }

                var translatedTitle: String?
                if let title = title {
                    translatedTitle = translations.firstOutput(matching: title)
                }

                let alert: AKActionSheet = .init(
                    title: translatedTitle,
                    message: translatedMessage,
                    actions: actions,
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
                return .failure(.translationFailed(error.localizedDescription))
            }
        }

        // MARK: - Translation Inputs

        private func translationInputs(for optionKeys: [TranslationOptionKey]) -> [TranslationInput] {
            var inputs = [TranslationInput]()
            for key in optionKeys {
                switch key {
                case let .actions(actions):
                    guard !actions.isEmpty else {
                        inputs.append(contentsOf: self.actions.map { .init($0.title) })
                        continue
                    }

                    inputs.append(contentsOf: self.actions.filter { actions.contains($0) }.map { .init($0.title) })

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

            var uniqueInputs = [TranslationInput]()
            for input in inputs where !uniqueInputs.contains(input) {
                uniqueInputs.append(input)
            }

            return uniqueInputs.filter { $0.value != Constants.defaultActionTitle }
        }
    }
}
