//
//  Array+InternalExtensions.swift
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
        guard index > -1,
              count > index else { return nil }

        return self[index]
    }
}

extension [AlertKit.Action] {
    func applying(
        _ translations: [Translation]
    ) -> [AlertKit.Action] {
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
    /// Returns the output of the first translation whose input matches
    /// the given string.
    ///
    /// - Parameter inputString: The string to match against each
    ///   translation's input value.
    ///
    /// - Returns: The output of the first matching translation, or the
    ///   given input string if no translation matches. In either case,
    ///   translation sentinel characters are removed from the result.
    func firstOutput(matching inputString: String) -> String {
        (first(where: { $0.input.value == inputString })?.output ?? inputString)
            .sanitized
    }
}

extension [TranslationInput] {
    var nonDefaultUnique: [TranslationInput] {
        unique.filter {
            $0.value != AlertKit.Constants.defaultActionTitle
        }
    }
}
