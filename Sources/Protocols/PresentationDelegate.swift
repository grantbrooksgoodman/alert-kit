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
        // MARK: - Properties

        var frontmostAlertController: UIAlertController? { get }

        // MARK: - Methods

        @MainActor
        func present(_ alertController: UIAlertController)
    }
}
