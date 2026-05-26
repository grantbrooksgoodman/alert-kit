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
    ) async throws -> [Translation] {
        try await getTranslations(
            inputs,
            languagePair: languagePair
        )
    }
}

@MainActor
extension AlertKit {
    static func getTranslations(
        for inputs: [TranslationInput]
    ) async throws -> [Translation] {
        let translator = AlertKit.config.translationDelegate ?? TranslationService.shared

        do {
            return try await translator.getTranslations(
                inputs,
                languagePair: .init(
                    from: AlertKit.config.sourceLanguageCode,
                    to: AlertKit.config.targetLanguageCode
                ),
                hud: AlertKit.config.translationHUDConfig,
                timeout: AlertKit.config.translationTimeoutConfig
            )
        } catch {
            throw AlertKit.Error.translationFailed(
                error.localizedDescription
            )
        }
    }

    static func presentWithTranslation<T, R>(
        shouldTranslate: Bool,
        presentDirectly: () async -> R,
        translate: () async throws -> T,
        presentTranslated: (T) async -> R,
        sender: Any,
        fileName: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) async -> R {
        guard shouldTranslate else { return await presentDirectly() }

        // Yield to the main run loop so pending UI work can complete
        // before a potentially long-running translation begins.
        await Task.yield()

        do {
            let translated = try await translate()

            // If the task was cancelled during translation (e.g., by
            // a caller-imposed timeout), fall back to untranslated
            // presentation to avoid indefinite stalling.
            guard !Task.isCancelled else {
                config.loggerDelegate?.log(
                    "Translation cancelled; presenting untranslated content.",
                    sender: sender,
                    fileName: fileName,
                    function: function,
                    line: line
                )

                return await presentDirectly()
            }

            return await presentTranslated(translated)
        } catch {
            config.loggerDelegate?.log(
                Task.isCancelled
                    ? "Translation cancelled; presenting untranslated content."
                    : error.localizedDescription,
                sender: sender,
                fileName: fileName,
                function: function,
                line: line
            )

            return await presentDirectly()
        }
    }
}
