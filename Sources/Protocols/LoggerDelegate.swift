//
//  LoggerDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    /// An interface for logging diagnostic messages from AlertKit
    /// operations.
    ///
    /// Implement this protocol to receive log output from AlertKit.
    /// Register your implementation through
    /// ``Config/registerLoggerDelegate(_:)``:
    ///
    /// ```swift
    /// AlertKit.config.registerLoggerDelegate(myDelegate)
    /// ```
    ///
    /// The ``reportsErrorsAutomatically`` property determines how
    /// ``ErrorAlert`` handles reportable errors. When this value is
    /// `false`, the alert includes a "Send Error Report" button.
    /// When `true`, the alert omits the button and instead displays
    /// the error identifier in the message body.
    @MainActor
    protocol LoggerDelegate {
        // MARK: - Properties

        /// A Boolean value that indicates whether reportable errors
        /// are filed automatically without requiring action from
        /// the user.
        ///
        /// When this value is `true`, ``ErrorAlert`` omits the
        /// "Send Error Report" button for reportable errors.
        var reportsErrorsAutomatically: Bool { get }

        // MARK: - Methods

        /// Logs a diagnostic message.
        ///
        /// - Parameters:
        ///   - text: The message to log.
        ///   - sender: The object or type that initiated the log
        ///     call.
        ///   - fileName: The source file in which the log call
        ///     occurs.
        ///   - function: The function in which the log call occurs.
        ///   - line: The line number at which the log call occurs.
        func log(
            _ text: String,
            sender: Any,
            fileName: String,
            function: String,
            line: Int
        )
    }
}
