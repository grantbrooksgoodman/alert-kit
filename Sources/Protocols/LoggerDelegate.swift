//
//  LoggerDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    protocol LoggerDelegate {
        // MARK: - Properties

        var reportsErrorsAutomatically: Bool { get }

        // MARK: - Methods

        func log(
            _ text: String,
            sender: Any,
            fileName: String,
            function: String,
            line: Int
        )
    }
}
