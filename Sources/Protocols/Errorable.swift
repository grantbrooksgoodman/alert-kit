//
//  Errorable.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    /// A type that represents an error suitable for display in an
    /// ``ErrorAlert``.
    ///
    /// Conform your error types to this protocol to present them
    /// using ``ErrorAlert``. The protocol provides the information
    /// that AlertKit needs to display the error and, optionally,
    /// file a report:
    ///
    /// ```swift
    /// struct MyError: AlertKit.Errorable {
    ///     let id: String
    ///     let isReportable: Bool
    ///     let metadataArray: [Any]
    ///     let userInfo: [String: Any]?
    ///     var description: String
    /// }
    /// ```
    ///
    /// - Note: The ``description`` property is declared with a
    ///   setter because AlertKit may replace it with a translated
    ///   value before presentation.
    protocol Errorable {
        /// The text that ``ErrorAlert`` presents to the user.
        ///
        /// This property is settable to allow AlertKit to replace
        /// it with a translated value.
        var description: String { get set }

        /// A unique identifier for the error.
        var id: String { get }

        /// A Boolean value that indicates whether the error can be
        /// reported through the ``ReportDelegate``.
        var isReportable: Bool { get }

        /// Additional metadata associated with the error.
        var metadataArray: [Any] { get }

        /// An optional dictionary of supplementary information
        /// about the error.
        var userInfo: [String: Any]? { get }
    }
}
