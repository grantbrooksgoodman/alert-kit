//
//  PresentationDelegate.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

public extension AlertKit {
    protocol PresentationDelegate {
        @MainActor
        func present(_ viewController: UIViewController)
    }
}
