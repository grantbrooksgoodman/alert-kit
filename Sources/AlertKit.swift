//
//  AlertKit.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

// MARK: - Type Aliases

public typealias AKAction = AlertKit.Action
public typealias AKActionSheet = AlertKit.ActionSheet
public typealias AKAlert = AlertKit.Alert
public typealias AKTextInputAlert = AlertKit.TextInputAlert

typealias Config = AlertKit.Config

// MARK: - AlertKit

public struct AlertKit {
    private init() {}
}

// MARK: - Config

public extension AlertKit {
    final class Config {
        /* MARK: Properties */

        // Singleton
        public static let shared = Config()

        // String
        public private(set) var sourceLanguageCode = "en"
        public private(set) var targetLanguageCode = Locale.systemLanguageCode

        // Delegates
        public private(set) var loggerDelegate: LoggerDelegate?
        public private(set) var presentationDelegate: PresentationDelegate?
        public private(set) var translationDelegate: TranslationDelegate?

        // Tuple
        public private(set) var translationHUDConfig: (appearsAfter: Duration, isModal: Bool) = (.seconds(2), true)
        public private(set) var translationTimeoutConfig: (duration: Duration, returnsInputs: Bool) = (.seconds(10), true)

        /* MARK: Init */

        private init() {}

        /* MARK: Delegate Registration */

        public func registerLoggerDelegate(_ loggerDelegate: LoggerDelegate) {
            self.loggerDelegate = loggerDelegate
        }

        public func registerPresentationDelegate(_ presentationDelegate: PresentationDelegate) {
            self.presentationDelegate = presentationDelegate
        }

        public func registerTranslationDelegate(_ translationDelegate: TranslationDelegate) {
            self.translationDelegate = translationDelegate
        }

        /* MARK: Value Overrides */

        public func overrideSourceLanguageCode(_ sourceLanguageCode: String) {
            self.sourceLanguageCode = sourceLanguageCode
        }

        public func overrideTargetLanguageCode(_ targetLanguageCode: String) {
            self.targetLanguageCode = targetLanguageCode
        }

        public func overrideTranslationHUDConfig(_ translationHUDConfig: (Duration, Bool)) {
            self.translationHUDConfig = translationHUDConfig
        }

        public func overrideTranslationTimeoutConfig(_ translationTimeoutConfig: (Duration, Bool)) {
            self.translationTimeoutConfig = translationTimeoutConfig
        }
    }
}

// MARK: - Constants

public extension AlertKit {
    enum Constants {
        public static let defaultActionTitle = "OK"
        public static let defaultCancelButtonTitle = "Cancel"
        public static let defaultConfirmButtonTitle = "Confirm"
    }
}
