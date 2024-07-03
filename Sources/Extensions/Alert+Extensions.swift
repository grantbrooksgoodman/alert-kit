//
//  Alert+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import Translator

extension AlertKit.Alert {
    func translate(_ keys: [AlertKit.TranslationOptionKey]) async -> Result<AKAlert, AlertKit.Error> {
        let translator = Config.shared.translationDelegate ?? TranslationService.shared
        guard !keys.isEmpty else { return .success(self) }

        let getTranslationsResult = await translator.getTranslations(
            translationInputs(for: keys),
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
                let title = translations.first(where: { $0.input.value == action.title })?.output ?? action.title
                actions.append(.init(
                    title,
                    isEnabled: action.isEnabled,
                    style: action.style,
                    effect: action.effect
                ))
            }

            let message = translations.first(where: { $0.input.value == self.message })?.output ?? message
            let title = translations.first(where: { $0.input.value == self.title })?.output ?? title

            return .success(.init(
                title: title,
                message: message,
                actions: actions
            ))

        case let .failure(error):
            return .failure(.translationFailed(error.localizedDescription))
        }
    }

    func translationInputs(for optionKeys: [AlertKit.TranslationOptionKey]) -> [TranslationInput] {
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
                inputs.append(.init(message))
                guard let title else { continue }
                inputs.append(.init(title))

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
