//
//  HUDConfig.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    /// A configuration that controls the appearance of a heads-up
    /// display shown during translation.
    ///
    /// When a translation takes longer than expected, AlertKit can
    /// display a HUD to indicate that work is in progress. Use
    /// `HUDConfig` to control when the HUD appears and whether it
    /// blocks interaction:
    ///
    /// ```swift
    /// AlertKit.config.overrideTranslationHUDConfig(
    ///     .init(appearsAfter: .seconds(1), isModal: true)
    /// )
    /// ```
    struct HUDConfig: Codable, Equatable, Sendable {
        // MARK: - Properties

        /// The duration to wait before displaying the HUD.
        public let appearsAfter: Duration

        /// A Boolean value that indicates whether the HUD prevents
        /// interaction with the underlying content.
        public let isModal: Bool

        // MARK: - Init

        /// Creates a HUD configuration with the specified delay and
        /// modality.
        ///
        /// - Parameters:
        ///   - appearsAfter: The duration to wait before displaying
        ///     the HUD.
        ///   - isModal: A Boolean value that indicates whether the
        ///     HUD prevents interaction with the underlying content.
        public init(
            appearsAfter: Duration,
            isModal: Bool
        ) {
            self.appearsAfter = appearsAfter
            self.isModal = isModal
        }
    }
}
