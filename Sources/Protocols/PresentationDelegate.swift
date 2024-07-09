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

        var keyViewController: UIViewController? { get }

        // MARK: - Methods

        @MainActor
        func present(_ viewController: UIViewController)
    }
}
