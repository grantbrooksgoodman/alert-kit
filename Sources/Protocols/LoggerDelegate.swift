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
        func log(_ text: String, metadata: [Any])
    }
}
