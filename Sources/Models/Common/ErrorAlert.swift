//
//  ErrorAlert.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

/* Proprietary */
import Translator

public extension AlertKit {
    /// An alert that presents an error to the user.
    ///
    /// Use `ErrorAlert` to display an error that conforms to the
    /// ``Errorable`` protocol. Create an error alert and present it:
    ///
    /// ```swift
    /// let alert = AKErrorAlert(error)
    /// await alert.present()
    /// ```
    ///
    /// When the error's ``Errorable/isReportable`` property is `true`,
    /// a ``ReportDelegate`` has been registered,
    /// and the logger delegate does not report errors automatically, the
    /// alert includes a "Send Error Report" button that files a report
    /// through the configured ``ReportDelegate``. Otherwise, the alert
    /// displays the error description as the title with the error
    /// identifier in the message body.
    ///
    /// By default, ``present(translating:)`` translates the error
    /// description and button titles into the configured target language.
    /// Pass an empty array to skip translation.
    @MainActor
    final class ErrorAlert {
        // MARK: - Properties

        private let dismissButtonTitle: String
        private let sendErrorReportButtonTitle: String

        /// The error that this alert presents.
        public private(set) var error: any Errorable

        // MARK: - Init

        /// Creates an error alert for the specified error.
        ///
        /// - Parameters:
        ///   - error: The error to present. The error's description is
        ///     displayed as the alert's message.
        ///   - dismissButtonTitle: The title of the dismiss button. The
        ///     default is "Dismiss".
        ///   - sendErrorReportButtonTitle: The title of the button that
        ///     files an error report. The default is
        ///     "Send Error Report".
        public init(
            _ error: any Errorable,
            dismissButtonTitle: String = Constants.defaultDismissButtonTitle,
            sendErrorReportButtonTitle: String = Constants.defaultSendErrorReportButtonTitle
        ) {
            self.error = error
            self.dismissButtonTitle = dismissButtonTitle
            self.sendErrorReportButtonTitle = sendErrorReportButtonTitle
        }

        // MARK: - Enable/Disable Actions

        /// Disables the action at the specified index in any currently
        /// presented alert controller.
        ///
        /// - Parameter index: The zero-based index of the action to
        ///   disable.
        public func disableAction(at index: Int) {
            Alert.disableAction(at: index)
        }

        /// Enables the action at the specified index in any currently
        /// presented alert controller.
        ///
        /// - Parameter index: The zero-based index of the action to
        ///   enable.
        public func enableAction(at index: Int) {
            Alert.enableAction(at: index)
        }

        // MARK: - Present

        /// Presents the error alert and suspends until the user
        /// dismisses it.
        ///
        /// This method translates the alert's content before presentation
        /// according to the specified keys. Each key identifies a part of
        /// the alert to translate. To skip translation, pass an empty
        /// array.
        ///
        /// - Parameter keys: The parts of the alert to translate. The
        ///   default includes all translatable content.
        public func present(
            translating keys: [TranslationOptionKey] = [
                .dismissButtonTitle,
                .errorDescription,
                .sendErrorReportButtonTitle,
            ]
        ) async {
            await AlertKit.presentWithTranslation(
                shouldTranslate: !keys.isEmpty,
                presentDirectly: {
                    await withCheckedContinuation { continuation in
                        let continuation = ContinuationGuard(
                            continuation,
                            fallbackValue: ()
                        )

                        present { continuation.resume(returning: ()) }
                    }
                },
                translate: { await translate(keys) },
                presentTranslated: { await $0.present(translating: []) },
                sender: self
            )
        }

        private func present(completion: @escaping () -> Void) {
            let alertController = UIAlertController(
                title: nil,
                message: error.description.sanitized,
                preferredStyle: .alert
            )

            if error.isReportable,
               AlertKit.config.loggerDelegate?.reportsErrorsAutomatically == false,
               let reportDelegate = AlertKit.config.reportDelegate {
                let reportAction = UIAlertAction(
                    title: sendErrorReportButtonTitle.sanitized,
                    style: .default
                ) { _ in
                    reportDelegate.fileReport(self.error)
                    completion()
                }

                alertController.addAction(reportAction)
                alertController.preferredAction = reportAction
            } else {
                alertController.title = error.description.sanitized
                alertController.message = "\n\(error.id)"
            }

            let dismissAction = UIAlertAction(
                title: dismissButtonTitle.sanitized,
                style: .cancel
            ) { _ in
                completion()
            }

            alertController.addAction(dismissAction)
            AlertKit.config.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<ErrorAlert, Error> {
            let uniqueKeys = keys.unique
            guard !uniqueKeys.isEmpty else { return .success(self) }

            let getTranslationsResult = await AlertKit.getTranslations(
                for: translationInputs(for: uniqueKeys)
            )

            switch getTranslationsResult {
            case let .success(translations):
                error.description = translations.firstOutput(matching: error.description)
                return .success(.init(
                    error,
                    dismissButtonTitle: translations.firstOutput(matching: dismissButtonTitle),
                    sendErrorReportButtonTitle: translations.firstOutput(matching: sendErrorReportButtonTitle)
                ))

            case let .failure(error):
                return .failure(error)
            }
        }

        // MARK: - Translation Inputs

        private func translationInputs(for optionKeys: [TranslationOptionKey]) -> [TranslationInput] {
            var inputs = [TranslationInput]()
            for key in optionKeys {
                switch key {
                case .dismissButtonTitle:
                    inputs.append(.init(dismissButtonTitle))

                case .errorDescription:
                    inputs.append(.init(error.description))

                case .sendErrorReportButtonTitle:
                    inputs.append(.init(sendErrorReportButtonTitle))
                }
            }

            return inputs.nonDefaultUnique
        }
    }
}
