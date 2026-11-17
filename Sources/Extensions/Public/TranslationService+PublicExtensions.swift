//
//  TranslationService+PublicExtensions.swift
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
    ) async throws -> [Translation] {
        try await getTranslations(
            inputs,
            languagePair: languagePair
        )
    }
}
