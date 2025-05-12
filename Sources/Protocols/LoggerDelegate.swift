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

        var reportsErrorsAutomatically: Bool { get set }

        // MARK: - Methods

        func log(_ text: String, metadata: [Any])
    }
}
