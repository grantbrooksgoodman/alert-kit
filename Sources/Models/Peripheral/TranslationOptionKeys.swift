//
//  TranslationOptionKeys.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

// MARK: - Alert

public extension AlertKit.Alert {
    enum TranslationOptionKey: Equatable {
        case actions([AKAction] = [])
        case all
        case message
        case title
    }
}

// MARK: - ActionSheet

public extension AlertKit.ActionSheet {
    enum TranslationOptionKey: Equatable {
        case actions([AKAction] = [])
        case all
        case cancelButtonTitle
        case message
        case title
    }
}

// MARK: - TextInputAlert

public extension AlertKit.TextInputAlert {
    enum TranslationOptionKey: Equatable {
        case all
        case cancelButtonTitle
        case confirmButtonTitle
        case message
        case placeholderText
        case sampleText
        case title
    }
}
