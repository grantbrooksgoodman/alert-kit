//
//  Array+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

/* 3rd-party */
import Translator

extension Array where Element == Translation {
    /// - Returns: If a matching output is not found within the array, the provided input string.
    func firstOutput(matching inputString: String) -> String {
        first(where: { $0.input.value == inputString })?.output ?? inputString
    }
}
