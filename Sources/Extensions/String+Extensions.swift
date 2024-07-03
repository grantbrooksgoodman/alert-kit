//
//  String+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

extension String {
    var sanitized: String {
        replacingOccurrences(of: "⌘", with: "").replacingOccurrences(of: "⁂", with: "")
    }
}
