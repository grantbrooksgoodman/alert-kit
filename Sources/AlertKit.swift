//
//  AlertKit.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

// MARK: - Type Aliases

/// A convenience alias for ``AlertKit/Action``.
public typealias AKAction = AlertKit.Action

/// A convenience alias for ``AlertKit/ActionSheet``.
public typealias AKActionSheet = AlertKit.ActionSheet

/// A convenience alias for ``AlertKit/Alert``.
public typealias AKAlert = AlertKit.Alert

/// A convenience alias for ``AlertKit/ConfirmationAlert``.
public typealias AKConfirmationAlert = AlertKit.ConfirmationAlert

/// A convenience alias for ``AlertKit/ErrorAlert``.
public typealias AKErrorAlert = AlertKit.ErrorAlert

/// A convenience alias for ``AlertKit/TextInputAlert``.
public typealias AKTextInputAlert = AlertKit.TextInputAlert

// MARK: - AlertKit

/// The top-level namespace for AlertKit types and configuration.
///
/// AlertKit provides a translation-aware alert presentation system
/// built on `UIAlertController`. Access the shared configuration
/// through the ``config`` property to register delegates and
/// customize behavior:
///
/// ```swift
/// AlertKit.config.registerPresentationDelegate(myDelegate)
/// AlertKit.config.registerTranslationDelegate(myDelegate)
/// ```
///
/// All alert types – ``Alert``, ``ActionSheet``,
/// ``ConfirmationAlert``, ``TextInputAlert``, and ``ErrorAlert`` –
/// are defined as nested types within this namespace.
@MainActor
public enum AlertKit {
    /// The shared configuration for AlertKit.
    public static let config = Config.shared
}

// MARK: - Config

public extension AlertKit {
    /// The configuration object for AlertKit.
    ///
    /// Use `Config` to register the delegates that control how
    /// AlertKit presents alerts, handles translations, logs
    /// messages, and files error reports. Access the shared instance
    /// through ``AlertKit/config``:
    ///
    /// ```swift
    /// AlertKit.config.registerPresentationDelegate(myDelegate)
    /// AlertKit.config.registerTranslationDelegate(myDelegate)
    /// AlertKit.config.registerLoggerDelegate(myDelegate)
    /// ```
    ///
    /// You can also override the default translation settings:
    ///
    /// ```swift
    /// AlertKit.config.overrideSourceLanguageCode("en")
    /// AlertKit.config.overrideTargetLanguageCode("fr")
    /// ```
    @MainActor
    final class Config {
        /* MARK: Properties */

        /// The registered inspection delegate, or `nil` if none
        /// has been registered.
        public private(set) var inspectionDelegate: InspectionDelegate?

        /// The registered logger delegate, or `nil` if none has
        /// been registered.
        public private(set) var loggerDelegate: LoggerDelegate?

        /// The registered presentation delegate, or `nil` if none
        /// has been registered.
        public private(set) var presentationDelegate: PresentationDelegate?

        /// The registered report delegate, or `nil` if none has
        /// been registered.
        public private(set) var reportDelegate: ReportDelegate?

        /// The ISO 639-1 language code of the source language for
        /// translations.
        ///
        /// The default value is `"en"`.
        public private(set) var sourceLanguageCode = "en"

        /// The ISO 639-1 language code of the target language for
        /// translations.
        ///
        /// The default value is the system's current language.
        public private(set) var targetLanguageCode = Locale.systemLanguageCode

        /// The registered translation delegate, or `nil` if none
        /// has been registered.
        public private(set) var translationDelegate: TranslationDelegate?

        /// The configuration for the heads-up display shown during
        /// translation.
        ///
        /// The default configuration displays the HUD after
        /// 2 seconds with modal behavior.
        public private(set) var translationHUDConfig: HUDConfig = .init(
            appearsAfter: .seconds(2),
            isModal: true
        )

        /// The configuration that controls translation timeout
        /// behavior.
        ///
        /// The default configuration uses a 10-second timeout and
        /// falls back to the original untranslated strings on
        /// failure.
        public private(set) var translationTimeoutConfig: TranslationTimeoutConfig = .init(
            .seconds(10),
            returnsInputsOnFailure: true
        )

        fileprivate static let shared = Config()

        /* MARK: Init */

        private init() {}

        /* MARK: Delegate Registration */

        /// Registers the given inspection delegate.
        ///
        /// - Parameter inspectionDelegate: The delegate to register.
        public func registerInspectionDelegate(_ inspectionDelegate: InspectionDelegate) {
            self.inspectionDelegate = inspectionDelegate
        }

        /// Registers the given logger delegate.
        ///
        /// - Parameter loggerDelegate: The delegate to register.
        public func registerLoggerDelegate(_ loggerDelegate: LoggerDelegate) {
            self.loggerDelegate = loggerDelegate
        }

        /// Registers the given presentation delegate.
        ///
        /// - Parameter presentationDelegate: The delegate to
        ///   register.
        public func registerPresentationDelegate(_ presentationDelegate: PresentationDelegate) {
            self.presentationDelegate = presentationDelegate
        }

        /// Registers the given report delegate.
        ///
        /// - Parameter reportDelegate: The delegate to register.
        public func registerReportDelegate(_ reportDelegate: ReportDelegate) {
            self.reportDelegate = reportDelegate
        }

        /// Registers the given translation delegate.
        ///
        /// - Parameter translationDelegate: The delegate to
        ///   register.
        public func registerTranslationDelegate(_ translationDelegate: TranslationDelegate) {
            self.translationDelegate = translationDelegate
        }

        /* MARK: Value Overrides */

        /// Overrides the source language code used for translations.
        ///
        /// - Parameter sourceLanguageCode: The ISO 639-1 language
        ///   code to use as the source language.
        public func overrideSourceLanguageCode(_ sourceLanguageCode: String) {
            self.sourceLanguageCode = sourceLanguageCode
        }

        /// Overrides the target language code used for
        /// translations.
        ///
        /// - Parameter targetLanguageCode: The ISO 639-1 language
        ///   code to use as the target language.
        public func overrideTargetLanguageCode(_ targetLanguageCode: String) {
            self.targetLanguageCode = targetLanguageCode
        }

        /// Overrides the translation HUD configuration.
        ///
        /// - Parameter translationHUDConfig: The HUD configuration
        ///   to use.
        public func overrideTranslationHUDConfig(_ translationHUDConfig: HUDConfig) {
            self.translationHUDConfig = translationHUDConfig
        }

        /// Overrides the translation timeout configuration.
        ///
        /// - Parameter translationTimeoutConfig: The timeout
        ///   configuration to use.
        public func overrideTranslationTimeoutConfig(_ translationTimeoutConfig: TranslationTimeoutConfig) {
            self.translationTimeoutConfig = translationTimeoutConfig
        }
    }
}

// MARK: - Constants

public extension AlertKit {
    /// Default string values used by AlertKit.
    enum Constants {
        /// The default title for a standard alert action (`"OK"`).
        public static let defaultActionTitle = "OK"

        /// The default title for a cancel button (`"Cancel"`).
        public static let defaultCancelButtonTitle = "Cancel"

        /// The default title for a confirm button (`"Confirm"`).
        public static let defaultConfirmButtonTitle = "Confirm"

        /// The default title for a dismiss button (`"Dismiss"`).
        public static let defaultDismissButtonTitle = "Dismiss"

        /// The default title for the send error report button
        /// (`"Send Error Report"`).
        public static let defaultSendErrorReportButtonTitle = "Send Error Report" // swiftlint:disable:next identifier_name

        /// The key used to set the attributed message on a
        /// `UIAlertController` through key-value coding.
        public static let uiAlertControllerAttributedMessageKeyName = "attributedMessage"

        /// The key used to set the attributed title on a
        /// `UIAlertController` through key-value coding.
        public static let uiAlertControllerAttributedTitleKeyName = "attributedTitle"
    }
}
