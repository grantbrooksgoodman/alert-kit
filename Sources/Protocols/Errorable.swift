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
        var id: String { get }
        var isReportable: Bool { get }
        var metadataArray: [Any] { get }
        var userInfo: [String: Any]? { get }
    }
}
