//
//  TextFieldAttributes.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

public extension AlertKit {
    /// A configuration that describes the appearance and behavior of
    /// a text field in a ``TextInputAlert``.
    ///
    /// Use `TextFieldAttributes` to customize properties such as the
    /// keyboard type, capitalization, and placeholder text:
    ///
    /// ```swift
    /// let attributes = AlertKit.TextFieldAttributes(
    ///     capitalizationType: .words,
    ///     keyboardType: .emailAddress,
    ///     placeholderText: "Email"
    /// )
    ///
    /// let alert = AKTextInputAlert(
    ///     message: "Enter your email.",
    ///     attributes: attributes
    /// )
    /// ```
    ///
    /// When you omit parameters, the text field uses sensible
    /// defaults: sentence capitalization, the standard keyboard, and
    /// center-aligned text.
    struct TextFieldAttributes: Hashable {
        // MARK: - Properties

        let capitalizationType: UITextAutocapitalizationType
        let clearButtonMode: UITextField.ViewMode
        let correctionType: UITextAutocorrectionType
        let isSecureTextEntry: Bool
        let keyboardAppearance: UIKeyboardAppearance
        let keyboardType: UIKeyboardType
        let placeholderText: String?
        let sampleText: String?
        let textAlignment: NSTextAlignment

        // MARK: - Init

        /// Creates a text field configuration with the specified
        /// attributes.
        ///
        /// - Parameters:
        ///   - capitalizationType: The autocapitalization style. The
        ///     default is `sentences`.
        ///   - clearButtonMode: When the clear button appears. The
        ///     default is `never`.
        ///   - correctionType: The autocorrection behavior. The
        ///     default is `default`.
        ///   - isSecureTextEntry: A Boolean value that indicates
        ///     whether the text field hides its input. The default
        ///     is `false`.
        ///   - keyboardAppearance: The keyboard's appearance. The
        ///     default is `default`.
        ///   - keyboardType: The type of keyboard to display. The
        ///     default is `default`.
        ///   - placeholderText: The placeholder text shown when the
        ///     field is empty. The default is `nil`.
        ///   - sampleText: The text prepopulated in the field. The
        ///     default is `nil`.
        ///   - textAlignment: The alignment of the text. The default
        ///     is `center`.
        public init(
            capitalizationType: UITextAutocapitalizationType = .sentences,
            clearButtonMode: UITextField.ViewMode = .never,
            correctionType: UITextAutocorrectionType = .default,
            isSecureTextEntry: Bool = false,
            keyboardAppearance: UIKeyboardAppearance = .default,
            keyboardType: UIKeyboardType = .default,
            placeholderText: String? = nil,
            sampleText: String? = nil,
            textAlignment: NSTextAlignment = .center
        ) {
            self.capitalizationType = capitalizationType
            self.clearButtonMode = clearButtonMode
            self.correctionType = correctionType
            self.isSecureTextEntry = isSecureTextEntry
            self.keyboardAppearance = keyboardAppearance
            self.keyboardType = keyboardType
            self.placeholderText = placeholderText
            self.sampleText = sampleText
            self.textAlignment = textAlignment
        }
    }
}

extension AlertKit.TextFieldAttributes {
    func replacingPlaceholderText(_ placeholderText: String) -> AlertKit.TextFieldAttributes {
        .init(
            capitalizationType: capitalizationType,
            clearButtonMode: clearButtonMode,
            correctionType: correctionType,
            isSecureTextEntry: isSecureTextEntry,
            keyboardAppearance: keyboardAppearance,
            keyboardType: keyboardType,
            placeholderText: placeholderText,
            sampleText: sampleText,
            textAlignment: textAlignment
        )
    }

    func replacingSampleText(_ sampleText: String) -> AlertKit.TextFieldAttributes {
        .init(
            capitalizationType: capitalizationType,
            clearButtonMode: clearButtonMode,
            correctionType: correctionType,
            isSecureTextEntry: isSecureTextEntry,
            keyboardAppearance: keyboardAppearance,
            keyboardType: keyboardType,
            placeholderText: placeholderText,
            sampleText: sampleText,
            textAlignment: textAlignment
        )
    }
}
