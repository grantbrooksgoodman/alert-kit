//
//  InspectionDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

public extension AlertKit {
    protocol InspectionDelegate {
        func sourceItem(_ tag: Int) -> UIView?
    }
}
