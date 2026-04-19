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

    /// Returns a copy of the string with translation sentinel
    /// characters removed.
    ///
    /// The characters `⌘` (U+2318), `⁂` (U+2042), and `※` (U+203B)
    /// are used as internal delimiters during translation
    /// tokenization. They must be stripped from all user-facing text
    /// before display.
    var sanitized: String {
        replacingOccurrences(of: "⌘", with: "")
            .replacingOccurrences(of: "⁂", with: "")
            .replacingOccurrences(of: "※", with: "")
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
