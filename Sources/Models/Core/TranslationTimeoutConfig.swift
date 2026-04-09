//
//  TranslationTimeoutConfig.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    struct TranslationTimeoutConfig: Codable, Equatable, Sendable {
        // MARK: - Properties

        public let duration: Duration
        public let returnsInputsOnFailure: Bool

        // MARK: - Init

        public init(
            _ duration: Duration,
            returnsInputsOnFailure: Bool
        ) {
            self.duration = duration
            self.returnsInputsOnFailure = returnsInputsOnFailure
        }
    }
}
