//
//  HUDConfig.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    struct HUDConfig: Codable, Equatable {
        // MARK: - Properties

        public let appearsAfter: Duration
        public let isModal: Bool

        // MARK: - Init

        public init(
            appearsAfter: Duration,
            isModal: Bool
        ) {
            self.appearsAfter = appearsAfter
            self.isModal = isModal
        }
    }
}
