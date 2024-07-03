//
//  Errorable.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    protocol Errorable {
        var description: String { get set }
        var extraParams: [String: Any]? { get }
        var id: String { get }
        var isReportable: Bool { get }
        var metadata: [Any] { get }
    }
}
