//
//  AttributedStringConfig.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

@MainActor
public extension AlertKit {
    struct AttributedStringConfig {
        // MARK: - Types

        public struct StringAttributes {
            /* MARK: Properties */

            let attributes: [NSAttributedString.Key: Any]
            let stringRanges: [String]

            /* MARK: Init */

            public init(
                _ attributes: [NSAttributedString.Key: Any],
                stringRanges: [String]
            ) {
                assert(!attributes.isEmpty && !stringRanges.isEmpty, "Instantiated StringAttributes with empty attributes or stringRanges array")
                self.attributes = attributes
                self.stringRanges = stringRanges.filter { !$0.isEmpty }.unique
            }
        }

        // MARK: - Properties

        let primaryAttributes: [NSAttributedString.Key: Any]
        let secondaryAttributes: [StringAttributes]?

        // MARK: - Init

        public init(
            _ primaryAttributes: [NSAttributedString.Key: Any],
            secondaryAttributes: [StringAttributes]? = nil
        ) {
            assert(
                !primaryAttributes.isEmpty,
                "Instantiated AttributedStringConfig with empty primaryAttributes dictionary"
            )

            self.primaryAttributes = primaryAttributes
            self.secondaryAttributes = secondaryAttributes
        }
    }
}
