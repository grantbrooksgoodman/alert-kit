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
    @MainActor
    protocol PresentationDelegate {
        // MARK: - Properties

        var presentedAlertControllers: [UIAlertController] { get }

        // MARK: - Methods

        func present(_ alertController: UIAlertController)
    }
}
