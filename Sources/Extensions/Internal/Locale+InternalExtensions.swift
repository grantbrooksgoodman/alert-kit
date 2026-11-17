//
//  Locale+InternalExtensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

@MainActor
extension Locale {
    static var systemLanguageCode: String {
        guard let languageCode = Bundle.main.preferredLocalizations.first ?? Locale.preferredLanguages.first ?? current.language.languageCode?.identifier,
              languageCode.count >= 2 else {
            return AlertKit.config.sourceLanguageCode
        }

        return languageCode.map { String($0) }[0 ... 1].joined()
    }
}
