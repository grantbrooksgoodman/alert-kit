//
//  TranslationOptionKey.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    enum TranslationOptionKey: Equatable {
        case actions([AKAction] = [])
        case all
        case message
        case title
    }
}
