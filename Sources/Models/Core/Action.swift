//
//  Action.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    struct Action: Equatable {
        // MARK: - Properties

        public let effect: () -> Void
        public let isEnabled: Bool
        public let style: ActionStyle
        public let title: String

        private let id = UUID()

        // MARK: - Init

        public init(
            _ title: String,
            isEnabled: Bool = true,
            style: ActionStyle = .default,
            effect: @escaping () -> Void
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
    }
}
