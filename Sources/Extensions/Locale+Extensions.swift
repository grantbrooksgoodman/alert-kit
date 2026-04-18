//
//  Locale+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

@MainActor
extension Locale {
    static var systemLanguageCode: String {
        let bundleLanguage = Bundle.main.preferredLocalizations.first
        let localeLanguage = Locale.preferredLanguages.first
        let currentLocaleLanguage = current.language.languageCode?.identifier

        let languageCode = bundleLanguage ?? localeLanguage ?? currentLocaleLanguage
        guard let languageCode,
              languageCode.count >= 2 else { return AlertKit.config.sourceLanguageCode }
        return languageCode.map { String($0) }[0 ... 1].joined()
    }
}
