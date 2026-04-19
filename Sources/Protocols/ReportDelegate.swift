//
//  ReportDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    /// An interface for filing error reports on behalf of the person
    /// using your app.
    ///
    /// Implement this protocol to handle error reporting when the
    /// user taps the "Send Error Report" button in an
    /// ``ErrorAlert``. Register your implementation through
    /// ``Config/registerReportDelegate(_:)``:
    ///
    /// ```swift
    /// AlertKit.config.registerReportDelegate(myDelegate)
    /// ```
    @MainActor
    protocol ReportDelegate {
        /// Files a report for the given error.
        ///
        /// AlertKit calls this method when the user taps the
        /// "Send Error Report" button in an ``ErrorAlert`` whose
        /// error is reportable.
        ///
        /// - Parameter error: The error to report.
        func fileReport(_ error: any Errorable)
    }
}
