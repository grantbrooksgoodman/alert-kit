//
//  Action.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

public extension AlertKit {
    /// A value that represents a button in an alert or action sheet.
    ///
    /// An `Action` pairs a title with a closure that executes when the
    /// user taps the corresponding button. You specify the action's
    /// visual style through its ``ActionStyle``:
    ///
    /// ```swift
    /// let action = AKAction("Delete", style: .destructive) {
    ///     deleteItem()
    /// }
    /// ```
    ///
    /// Pass one or more actions to an ``Alert`` or ``ActionSheet`` at
    /// initialization.
    struct Action: Hashable, Sendable {
        // MARK: - Properties

        let effect: @Sendable () -> Void
        let isEnabled: Bool
        let style: ActionStyle
        let title: String

        /// A unique identifier for this action instance, used in
        /// equality checks and hashing to distinguish actions by
        /// identity rather than by value alone. Two actions with the
        /// same title, style, and enabled state are not equal if they
        /// are different instances.
        ///
        /// This means filtering via `.actions([...])` in a
        /// `TranslationOptionKey` requires the exact original
        /// `Action` references – newly constructed actions with
        /// identical properties will not match.
        private let id = UUID()

        // MARK: - Init

        /// Creates an action with the specified title, enabled state,
        /// style, and effect.
        ///
        /// - Parameters:
        ///   - title: The title displayed on the action's button.
        ///   - isEnabled: A Boolean value that determines whether the
        ///     action is enabled. The default is `true`.
        ///   - style: The style applied to the action's button. The
        ///     default is ``ActionStyle/default``.
        ///   - effect: The closure to execute when the user taps the
        ///     action's button.
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

        func perform() {
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
