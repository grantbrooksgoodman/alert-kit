//
//  UITextField+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

extension UITextField {
    func configure(with attributes: AlertKit.TextFieldAttributes) {
        autocapitalizationType = attributes.capitalizationType
        autocorrectionType = attributes.correctionType
        clearButtonMode = attributes.clearButtonMode
        isSecureTextEntry = attributes.isSecureTextEntry
        keyboardAppearance = attributes.keyboardAppearance
        keyboardType = attributes.keyboardType
        placeholder = attributes.placeholderText?.sanitized
        text = attributes.sampleText?.sanitized
        textAlignment = attributes.textAlignment
    }
}
