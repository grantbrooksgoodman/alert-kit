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
    enum SourceItem {
        // MARK: - Types

        public enum CustomSourceItem {
            case string(String)
            case view(UIView?)
        }

        // MARK: - Cases

        case custom(CustomSourceItem)
        case message
        case title
    }
}
