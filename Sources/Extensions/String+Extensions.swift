//
//  String+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

extension String {
    // MARK: - Properties

    var sanitized: String {
        replacingOccurrences(of: "⌘", with: "").replacingOccurrences(of: "⁂", with: "")
    }

    // MARK: - Methods

    func attributed(_ config: AlertKit.AttributedStringConfig) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self, attributes: config.primaryAttributes)
        func applyAttributes(_ attributes: [NSAttributedString.Key: Any], stringRanges: [String]) {
            stringRanges.filter { self.contains($0) }.forEach { string in
                attributedString.addAttributes(
                    attributes,
                    range: (self as NSString).range(of: (string as NSString) as String)
                )
            }
        }

        config.secondaryAttributes?.forEach { applyAttributes($0.attributes, stringRanges: $0.stringRanges) }
        return attributedString
    }
}
