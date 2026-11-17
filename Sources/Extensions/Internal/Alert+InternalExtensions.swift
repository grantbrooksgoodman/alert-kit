//
//  Alert+InternalExtensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

@MainActor
extension AlertKit.Alert {
    // MARK: - Properties

    private static var presentedAlertControllers: [UIAlertController] {
        AlertKit
            .config
            .presentationDelegate?
            .presentedAlertControllers ?? []
    }

    // MARK: - Methods

    static func disableAction(at index: Int) {
        presentedAlertControllers.forEach { $0.actions.itemAt(index)?.isEnabled = false }
    }

    static func enableAction(at index: Int) {
        presentedAlertControllers.forEach { $0.actions.itemAt(index)?.isEnabled = true }
    }
}
