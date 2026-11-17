//
//  TextFieldAttributes+InternalExtensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

extension AlertKit.TextFieldAttributes {
    func replacingPlaceholderText(
        _ placeholderText: String
    ) -> AlertKit.TextFieldAttributes {
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

    func replacingSampleText(
        _ sampleText: String
    ) -> AlertKit.TextFieldAttributes {
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
