//
//  Alert+Extensions.swift
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

    private static var presentedAlertControllers: [UIAlertController] { Config.shared.presentationDelegate?.presentedAlertControllers ?? [] }

    // MARK: - Methods

    static func enableAction(at index: Int) {
        presentedAlertControllers.forEach { $0.actions.itemAt(index)?.isEnabled = true }
    }

    static func disableAction(at index: Int) {
        presentedAlertControllers.forEach { $0.actions.itemAt(index)?.isEnabled = false }
    }
}
