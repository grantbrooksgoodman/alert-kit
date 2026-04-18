//
//  TranslationService+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

/* Proprietary */
import Translator

@MainActor
extension TranslationService: AlertKit.TranslationDelegate {
    public func getTranslations(
        _ inputs: [TranslationInput],
        languagePair: LanguagePair,
        hud hudConfig: AlertKit.HUDConfig? = nil,
        timeout timeoutConfig: AlertKit.TranslationTimeoutConfig = AlertKit.config.translationTimeoutConfig
    ) async -> Result<[Translation], TranslationError> {
        await getTranslations(
            inputs,
            languagePair: languagePair
        )
    }
}

@MainActor
extension AlertKit {
    static func getTranslations(
        for inputs: [TranslationInput]
    ) async -> Result<[Translation], Error> {
        let translator = AlertKit.config.translationDelegate ?? TranslationService.shared

        let getTranslationsResult = await translator.getTranslations(
            inputs,
            languagePair: .init(
                from: AlertKit.config.sourceLanguageCode,
                to: AlertKit.config.targetLanguageCode
            ),
            hud: AlertKit.config.translationHUDConfig,
            timeout: AlertKit.config.translationTimeoutConfig
        )

        switch getTranslationsResult {
        case let .success(translations):
            return .success(translations)

        case let .failure(error):
            return .failure(.translationFailed(
                error.localizedDescription
            ))
        }
    }

    static func presentWithTranslation<T, R>(
        shouldTranslate: Bool,
        presentDirectly: () async -> R,
        translate: () async -> Result<T, Error>,
        presentTranslated: (T) async -> R,
        sender: Any,
        fileName: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) async -> R {
        guard shouldTranslate else { return await presentDirectly() }
        let translateResult = await translate()

        switch translateResult {
        case let .success(translated):
            return await presentTranslated(translated)

        case let .failure(error):
            config.loggerDelegate?.log(
                error.localizedDescription,
                sender: sender,
                fileName: fileName,
                function: function,
                line: line
            )

            return await presentDirectly()
        }
    }
}
