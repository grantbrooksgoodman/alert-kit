//
//  TranslationOptionKeys.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

// MARK: - ActionSheet

public extension AlertKit.ActionSheet {
    enum TranslationOptionKey: Hashable, Sendable {
        case actions([AlertKit.Action] = [])
        case cancelButtonTitle
        case message
        case title
    }
}

// MARK: - Alert

public extension AlertKit.Alert {
    enum TranslationOptionKey: Hashable, Sendable {
        case actions([AlertKit.Action] = [])
        case message
        case title
    }
}

// MARK: - ConfirmationAlert

public extension AlertKit.ConfirmationAlert {
    enum TranslationOptionKey: Hashable, Sendable {
        case cancelButtonTitle
        case confirmButtonTitle
        case message
        case title
    }
}

// MARK: - ErrorAlert

public extension AlertKit.ErrorAlert {
    enum TranslationOptionKey: Hashable, Sendable {
        case dismissButtonTitle
        case errorDescription
        case sendErrorReportButtonTitle
    }
}

// MARK: - TextInputAlert

public extension AlertKit.TextInputAlert {
    enum TranslationOptionKey: Hashable, Sendable {
        case cancelButtonTitle
        case confirmButtonTitle
        case message
        case placeholderText
        case sampleText
        case title
    }
}
