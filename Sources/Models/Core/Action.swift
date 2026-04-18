//
//  Action.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    struct Action: Hashable, Sendable {
        // MARK: - Properties

        let effect: @Sendable () -> Void
        let isEnabled: Bool
        let style: ActionStyle
        let title: String

        private let id = UUID()

        // MARK: - Init

        public init(
            _ title: String,
            isEnabled: Bool = true,
            style: ActionStyle = .default,
            effect: @escaping @Sendable () -> Void
        ) {
            self.title = title
            self.isEnabled = isEnabled
            self.style = style
            self.effect = effect
        }

        // MARK: - Perform

        public func perform() {
            effect()
        }

        // MARK: - Equatable Conformance

        public static func == (left: Action, right: Action) -> Bool {
            let sameID = left.id == right.id
            let sameIsEnabled = left.isEnabled == right.isEnabled
            let sameStyle = left.style == right.style
            let sameTitle = left.title == right.title

            guard sameID,
                  sameIsEnabled,
                  sameStyle,
                  sameTitle else { return false }

            return true
        }

        // MARK: - Hashable Conformance

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(isEnabled)
            hasher.combine(style)
            hasher.combine(title)
        }
    }
}
