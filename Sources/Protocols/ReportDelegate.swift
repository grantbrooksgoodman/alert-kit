//
//  ReportDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    protocol ReportDelegate {
        func fileReport(_ error: any Errorable)
    }
}
