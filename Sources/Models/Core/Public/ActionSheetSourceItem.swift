//
//  ActionSheetSourceItem.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

public extension AlertKit.ActionSheet {
    /// A value that identifies the element an action sheet's popover
    /// anchors to on iOS 26 and later.
    ///
    /// On iOS 26 and later, action sheets may be presented as popovers.
    /// Use a source item to specify the view that the popover's arrow points to.
    /// Pass a source item when creating an ``ActionSheet``:
    ///
    /// ```swift
    /// let actionSheet = AKActionSheet(
    ///     title: "Options",
    ///     actions: actions,
    ///     sourceItem: .title
    /// )
    /// ```
    enum SourceItem {
        // MARK: - Types

        /// A value that identifies a custom source element for an
        /// action sheet's popover.
        public enum CustomSourceItem {
            /// A source item identified by a string.
            case string(String)

            /// A source item using the specified view directly.
            case view(UIView?)
        }

        // MARK: - Cases

        /// A custom source item.
        case custom(CustomSourceItem)

        /// The view associated with the action sheet's message.
        case message

        /// The view associated with the action sheet's title.
        case title
    }
}
