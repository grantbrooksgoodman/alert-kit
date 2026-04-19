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
    /// Constants that indicate the visual style of an action's button.
    ///
    /// Use action styles to communicate the nature of an action to the
    /// user. For example, use ``destructive`` for actions that delete
    /// data, or ``cancel`` for actions that dismiss the alert without
    /// making changes.
    ///
    /// The ``preferred`` and ``destructivePreferred`` styles set the
    /// corresponding button as the alert's preferred action, giving it
    /// visual emphasis.
    enum ActionStyle: Codable, Equatable, Sendable {
        // MARK: - Cases

        /// An action that cancels the alert and leaves things unchanged.
        case cancel

        /// The default style for an action button.
        case `default`

        /// A style that indicates the action might change or delete
        /// data.
        case destructive

        /// A destructive action that is also the alert's preferred
        /// action.
        case destructivePreferred

        /// An action that is the alert's preferred action.
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
