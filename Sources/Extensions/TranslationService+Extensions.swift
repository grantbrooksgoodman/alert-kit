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
        timeout timeoutConfig: AlertKit.TranslationTimeoutConfig = AlertKit.Config.shared.translationTimeoutConfig
    ) async -> Result<[Translation], TranslationError> {
        await getTranslations(
            inputs,
            languagePair: languagePair
        )
    }
}
