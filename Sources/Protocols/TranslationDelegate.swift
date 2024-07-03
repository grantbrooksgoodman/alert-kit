//
//  TranslationDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

/* Proprietary */
import Translator

public extension AlertKit {
    protocol TranslationDelegate {
        func getTranslations(
            _ inputs: [TranslationInput],
            languagePair: LanguagePair,
            hud hudConfig: HUDConfig?,
            timeout timeoutConfig: TranslationTimeoutConfig
        ) async -> Result<[Translation], TranslationError>
    }
}
