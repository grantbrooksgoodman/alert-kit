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

extension Array where Element == Translation {
    /// - Returns: If a matching output is not found within the array, the provided input string.
    func firstOutput(matching inputString: String) -> String {
        (first(where: { $0.input.value == inputString })?.output ?? inputString).sanitized
    }
}
