//
//  Error.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    enum Error: Codable, LocalizedError, Equatable {
        // MARK: - Cases

        case translationFailed(String)

        // MARK: - Properties

        public var errorDescription: String? {
            switch self {
            case let .translationFailed(errorDescription):
                return "Translation failed: \(errorDescription)"
            }
        }
    }
}
