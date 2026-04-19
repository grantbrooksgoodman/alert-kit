//
//  Array+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

/* Proprietary */
import Translator

extension Array {
    func itemAt(_ index: Int) -> Element? {
        guard index > -1, count > index else { return nil }
        return self[index]
    }
}

extension [AlertKit.Action] {
    func applying(_ translations: [Translation]) -> [AlertKit.Action] {
        map {
            .init(
                translations.firstOutput(matching: $0.title),
                isEnabled: $0.isEnabled,
                style: $0.style,
                effect: $0.effect
            )
        }
    }
}

extension [Translation] {
    /// - Returns: If a matching output is not found within the array, the provided input string.
    func firstOutput(matching inputString: String) -> String {
        (first(where: { $0.input.value == inputString })?.output ?? inputString).sanitized
    }
}

extension [TranslationInput] {
    var nonDefaultUnique: [TranslationInput] {
        unique.filter {
            $0.value != AlertKit.Constants.defaultActionTitle
        }
    }
}
