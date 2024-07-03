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
    enum ActionStyle: Codable, Equatable {
        // MARK: - Cases

        case cancel
        case `default`
        case destructive
        case destructivePreferred
        case preferred

        // MARK: - Properties

        public var uiAlertStyle: UIAlertAction.Style {
            switch self {
            case .cancel:
                return .cancel

            case .default,
                 .preferred:
                return .default

            case .destructive,
                 .destructivePreferred:
                return .destructive
            }
        }
    }
}
