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
public typealias AKConfirmationAlert = AlertKit.ConfirmationAlert
public typealias AKErrorAlert = AlertKit.ErrorAlert
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
        public private(set) var inspectionDelegate: InspectionDelegate?
        public private(set) var loggerDelegate: LoggerDelegate?
        public private(set) var presentationDelegate: PresentationDelegate?
        public private(set) var reportDelegate: ReportDelegate?
        public private(set) var translationDelegate: TranslationDelegate?

        // Translation Configurations
        public private(set) var translationHUDConfig: HUDConfig = .init(
            appearsAfter: .seconds(2),
            isModal: true
        )
        public private(set) var translationTimeoutConfig: TranslationTimeoutConfig = .init(
            .seconds(10),
            returnsInputsOnFailure: true
        )

        /* MARK: Init */

        private init() {}

        /* MARK: Delegate Registration */

        public func registerInspectionDelegate(_ inspectionDelegate: InspectionDelegate) {
            self.inspectionDelegate = inspectionDelegate
        }

        public func registerLoggerDelegate(_ loggerDelegate: LoggerDelegate) {
            self.loggerDelegate = loggerDelegate
        }

        public func registerPresentationDelegate(_ presentationDelegate: PresentationDelegate) {
            self.presentationDelegate = presentationDelegate
        }

        public func registerReportDelegate(_ reportDelegate: ReportDelegate) {
            self.reportDelegate = reportDelegate
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

        public func overrideTranslationHUDConfig(_ translationHUDConfig: HUDConfig) {
            self.translationHUDConfig = translationHUDConfig
        }

        public func overrideTranslationTimeoutConfig(_ translationTimeoutConfig: TranslationTimeoutConfig) {
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
        public static let defaultDismissButtonTitle = "Dismiss"
        public static let defaultSendErrorReportButtonTitle = "Send Error Report" // swiftlint:disable:next identifier_name
        public static let uiAlertControllerAttributedMessageKeyName = "attributedMessage"
        public static let uiAlertControllerAttributedTitleKeyName = "attributedTitle"
    }
}
