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
    @MainActor
    final class ErrorAlert {
        // MARK: - Properties

        private let dismissButtonTitle: String
        private let sendErrorReportButtonTitle: String

        public private(set) var error: any Errorable

        // MARK: - Init

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

        public func disableAction(at index: Int) {
            Alert.disableAction(at: index)
        }

        public func enableAction(at index: Int) {
            Alert.enableAction(at: index)
        }

        // MARK: - Present

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
                        present { continuation.resume() }
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
               AlertKit.config.loggerDelegate?.reportsErrorsAutomatically == false {
                let reportAction = UIAlertAction(
                    title: sendErrorReportButtonTitle.sanitized,
                    style: .default
                ) { _ in
                    AlertKit.config.reportDelegate?.fileReport(self.error)
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
