//
//  UIApplication+Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

extension UIApplication {
    static let isV26Compatible: Bool = !UIApplication.bundleRequiresPreV26Design &&
        UIApplication.iOS26IsAvailable &&
        UIApplication.isCompiledForV26OrLater

    private static let bundleRequiresPreV26Design: Bool = Bundle.main.object(
        forInfoDictionaryKey: "UIDesignRequiresCompatibility"
    ) as? Bool ?? false

    private static let iOS26IsAvailable: Bool = {
        if #available(iOS 26, *) { return true }
        return false
    }()

    private static let isCompiledForV26OrLater: Bool = {
        #if compiler(>=6.2)
        return true
        #else
        return false
        #endif
    }()
}
