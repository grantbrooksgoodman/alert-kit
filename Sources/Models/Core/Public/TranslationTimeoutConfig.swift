//
//  TranslationTimeoutConfig.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    /// A configuration that controls how AlertKit handles translation
    /// timeouts.
    ///
    /// Use `TranslationTimeoutConfig` to specify how long to wait for
    /// translations and what to do when they time out:
    ///
    /// ```swift
    /// AlertKit.config.overrideTranslationTimeoutConfig(
    ///     .init(.seconds(5), returnsInputsOnFailure: true)
    /// )
    /// ```
    ///
    /// When `returnsInputsOnFailure` is `true`, a timed-out
    /// translation falls back to the original untranslated strings
    /// rather than presenting an error.
    struct TranslationTimeoutConfig: Codable, Equatable, Sendable {
        // MARK: - Properties

        /// The maximum duration to wait for a translation to complete.
        public let duration: Duration

        /// A Boolean value that indicates whether the alert presents
        /// the original untranslated strings when a translation times
        /// out.
        ///
        /// When this value is `true`, a timed-out translation falls
        /// back to the original input strings. When `false`, the
        /// timeout is reported as an error.
        public let returnsInputsOnFailure: Bool

        // MARK: - Init

        /// Creates a translation timeout configuration with the
        /// specified duration and failure behavior.
        ///
        /// - Parameters:
        ///   - duration: The maximum duration to wait for a
        ///     translation to complete.
        ///   - returnsInputsOnFailure: A Boolean value that indicates
        ///     whether to fall back to the original untranslated
        ///     strings on timeout.
        public init(
            _ duration: Duration,
            returnsInputsOnFailure: Bool
        ) {
            self.duration = duration
            self.returnsInputsOnFailure = returnsInputsOnFailure
        }
    }
}
