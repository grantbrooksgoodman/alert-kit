//
//  ActionSheet.swift
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
    struct ActionSheet: Equatable {
        // MARK: - Properties

        // Array
        public let actions: [AKAction]

        // String
        public let cancelButtonTitle: String
        public let message: String
        public let title: String?

        // MARK: - Init

        public init(
            title: String? = nil,
            message: String,
            actions: [AKAction],
            cancelButtonTitle: String = "Cancel"
        ) {
            assert(!actions.isEmpty, "Modal alerts are not supported")
            assert(!actions.contains(where: { $0.style == .cancel }), "Action sheets include cancel buttons by default")
            self.title = title
            self.message = message
            self.actions = actions
            self.cancelButtonTitle = cancelButtonTitle
        }

        // MARK: - Present

        @MainActor
        public func present(translating keys: [TranslationOptionKey] = [.all]) async {
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
                preferredStyle: .actionSheet
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

            let cancelAction = UIAlertAction(
                title: cancelButtonTitle,
                style: .cancel
            ) { _ in
                completion()
            }
            alertController.addAction(cancelAction)

            Config.shared.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<AKActionSheet, Error> {
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
                var actions = [AKAction]()
                for action in self.actions {
                    actions.append(.init(
                        translations.firstOutput(matching: action.title),
                        isEnabled: action.isEnabled,
                        style: action.style,
                        effect: action.effect
                    ))
                }

                var translatedTitle: String?
                if let title = title {
                    translatedTitle = translations.firstOutput(matching: title)
                }

                return .success(.init(
                    title: translatedTitle,
                    message: translations.firstOutput(matching: message),
                    actions: actions,
                    cancelButtonTitle: translations.firstOutput(matching: cancelButtonTitle)
                ))

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

                case .all:
                    inputs.append(contentsOf: actions.map { .init($0.title) })
                    inputs.append(.init(cancelButtonTitle))
                    inputs.append(.init(message))
                    guard let title else { continue }
                    inputs.append(.init(title))

                case .cancelButtonTitle:
                    inputs.append(.init(cancelButtonTitle))

                case .message:
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

            return uniqueInputs.filter { $0.value != "OK" }
        }
    }
}
