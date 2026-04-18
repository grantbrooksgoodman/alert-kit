//
//  ActionStyle.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

public extension AlertKit {
    enum ActionStyle: Codable, Equatable, Sendable {
        // MARK: - Cases

        case cancel
        case `default`
        case destructive
        case destructivePreferred
        case preferred

        // MARK: - Properties

        var uiAlertStyle: UIAlertAction.Style {
            switch self {
            case .cancel:
                .cancel

            case .default,
                 .preferred:
                .default

            case .destructive,
                 .destructivePreferred:
                .destructive
            }
        }
    }
}
