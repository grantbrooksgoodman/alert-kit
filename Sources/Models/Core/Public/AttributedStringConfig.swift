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
    /// A configuration that describes how to style an alert's title or
    /// message as an attributed string.
    ///
    /// Use `AttributedStringConfig` to customize the appearance of an
    /// alert's text beyond what the system provides by default. Apply a
    /// configuration by calling ``Alert/setTitleAttributes(_:)`` or
    /// ``Alert/setMessageAttributes(_:)`` before presenting the alert:
    ///
    /// ```swift
    /// let alert = AKAlert(message: "Operation complete.")
    ///
    /// alert.setMessageAttributes(
    ///     .init([.font: UIFont.boldSystemFont(ofSize: 17)])
    /// )
    ///
    /// await alert.present()
    /// ```
    ///
    /// To apply different attributes to specific substrings, provide
    /// one or more ``StringAttributes`` as secondary attributes:
    ///
    /// ```swift
    /// let config = AlertKit.AttributedStringConfig(
    ///     [.font: UIFont.systemFont(ofSize: 15)],
    ///     secondaryAttributes: [
    ///         .init(
    ///             [.foregroundColor: UIColor.red],
    ///             stringRanges: ["important"]
    ///         ),
    ///     ]
    /// )
    /// ```
    ///
    /// - Important: The `primaryAttributes` dictionary must not be
    ///   empty. Passing an empty dictionary triggers a runtime
    ///   assertion failure.
    struct AttributedStringConfig {
        // MARK: - Types

        /// A set of attributes to apply to specific substrings within
        /// an attributed string.
        ///
        /// - Important: Both the `attributes` dictionary and the
        ///   `stringRanges` array must not be empty. Passing empty
        ///   values triggers a runtime assertion failure.
        public struct StringAttributes {
            /* MARK: Properties */

            let attributes: [NSAttributedString.Key: Any]
            let stringRanges: [String]

            /* MARK: Init */

            /// Creates a set of string attributes for the specified
            /// ranges.
            ///
            /// - Parameters:
            ///   - attributes: The text attributes to apply.
            ///   - stringRanges: The substrings to apply the attributes
            ///     to. Empty strings are filtered out, and duplicates
            ///     are removed.
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

        /// Creates an attributed string configuration with the
        /// specified primary and optional secondary attributes.
        ///
        /// - Parameters:
        ///   - primaryAttributes: The text attributes applied to the
        ///     entire string.
        ///   - secondaryAttributes: An optional array of
        ///     ``StringAttributes`` applied to specific substrings.
        ///     The default is `nil`.
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
