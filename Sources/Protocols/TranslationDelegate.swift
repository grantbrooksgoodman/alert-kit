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
    /// An interface for providing translation services to AlertKit.
    ///
    /// Implement this protocol to supply translations for alert
    /// content. AlertKit calls
    /// ``getTranslations(_:languagePair:hud:timeout:)`` before
    /// presenting any alert whose `translating` keys are non-empty.
    ///
    /// Register your implementation through
    /// ``Config/registerTranslationDelegate(_:)``:
    ///
    /// ```swift
    /// AlertKit.config.registerTranslationDelegate(myDelegate)
    /// ```
    @MainActor
    protocol TranslationDelegate {
        /// Translates the given inputs and returns the results.
        ///
        /// - Parameters:
        ///   - inputs: The translation inputs to translate.
        ///   - languagePair: The source and target languages for
        ///     the translation.
        ///   - hudConfig: The configuration for the translation
        ///     HUD, or `nil` to suppress the HUD.
        ///   - timeoutConfig: The configuration that controls
        ///     timeout behavior.
        ///
        /// - Returns: A `Result` containing the completed
        ///   translations on success, or a `TranslationError` on
        ///   failure.
        func getTranslations(
            _ inputs: [TranslationInput],
            languagePair: LanguagePair,
            hud hudConfig: HUDConfig?,
            timeout timeoutConfig: TranslationTimeoutConfig
        ) async -> Result<[Translation], TranslationError>
    }
}
