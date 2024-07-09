//
//  Alert.swift
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
    final class Alert {
        // MARK: - Properties

        // Array
        private let actions: [Action]

        // NSAttributedString
        private var attributedMessage: NSAttributedString?
        private var attributedTitle: NSAttributedString?

        // String
        private let message: String
        private let title: String?

        // MARK: - Init

        public init(
            title: String? = nil,
            message: String,
            actions: [Action] = [.init(Constants.defaultActionTitle, style: .cancel, effect: {})]
        ) {
            assert(!actions.isEmpty, "Modal alerts are not supported")
            self.title = title
            self.message = message
            self.actions = actions
        }

        // MARK: - Set Attributed Strings

        public func setAttributedMessage(_ attributedMessage: NSAttributedString) {
            self.attributedMessage = attributedMessage
        }

        public func setAttributedTitle(_ attributedTitle: NSAttributedString) {
            self.attributedTitle = attributedTitle
        }

        // MARK: - Present

        @MainActor
        public func present(
            translating keys: [TranslationOptionKey] = [
                .actions(),
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
                    metadata: [self, #file, #function, #line]
                )
                return await present(translating: [])
            }
        }

        @MainActor
        private func present(completion: @escaping () -> Void) {
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            for action in actions {
                let alertAction = UIAlertAction(
                    title: action.title,
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

            if let attributedMessage {
                alertController.setValue(attributedMessage, forKey: Constants.uiAlertControllerAttributedMessageKeyName)
            }

            if let attributedTitle {
                alertController.setValue(attributedTitle, forKey: Constants.uiAlertControllerAttributedTitleKeyName)
            }

            Config.shared.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<Alert, Error> {
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

                var translatedTitle: String?
                if let title {
                    translatedTitle = translations.firstOutput(matching: title)
                }

                let alert: AKAlert = .init(
                    title: translatedTitle,
                    message: translations.firstOutput(matching: message),
                    actions: actions
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
                case let .actions(actions):
                    guard !actions.isEmpty else {
                        inputs.append(contentsOf: self.actions.map { .init($0.title) })
                        continue
                    }

                    inputs.append(contentsOf: self.actions.filter { actions.contains($0) }.map { .init($0.title) })

                case .message:
                    guard let attributedMessage else {
                        inputs.append(.init(message))
                        continue
                    }

                    inputs.append(.init(attributedMessage.string))

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
