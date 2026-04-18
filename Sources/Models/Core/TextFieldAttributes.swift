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
