//
//  Error.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    /// Errors that AlertKit methods can produce.
    enum Error: Codable, LocalizedError, Equatable {
        // MARK: - Cases

        /// A translation operation failed.
        ///
        /// The associated string contains a description of the
        /// underlying failure.
        case translationFailed(String)

        // MARK: - Properties

        /// A human-readable description of the error.
        public var errorDescription: String? {
            switch self {
            case let .translationFailed(errorDescription):
                "Translation failed: \(errorDescription)"
            }
        }
    }
}
