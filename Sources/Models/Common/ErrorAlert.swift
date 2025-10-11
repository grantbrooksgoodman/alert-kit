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
    final class ErrorAlert {
        // MARK: - Properties

        // Errorable
        public private(set) var error: any Errorable

        // String
        public let dismissButtonTitle: String
        public let sendErrorReportButtonTitle: String

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

        @MainActor
        public func disableAction(at index: Int) {
            Alert.disableAction(at: index)
        }

        @MainActor
        public func enableAction(at index: Int) {
            Alert.enableAction(at: index)
        }

        // MARK: - Present

        @MainActor
        public func present(
            translating keys: [TranslationOptionKey] = [
                .dismissButtonTitle,
                .errorDescription,
                .sendErrorReportButtonTitle,
            ]
        ) async {
            guard !keys.isEmpty else {
                return await withCheckedContinuation { continuation in
                    present { continuation.resume() }
                }
            }

            let translateResult = await translate(keys)

            switch translateResult {
            case let .success(alert):
                return await alert.present(translating: [])

            case let .failure(error):
                Config.shared.loggerDelegate?.log(
                    error.localizedDescription,
                    sender: self,
                    fileName: #fileID,
                    function: #function,
                    line: #line
                )
                return await present(translating: [])
            }
        }

        @MainActor
        private func present(completion: @escaping () -> Void) {
            let alertController = UIAlertController(
                title: nil,
                message: error.description.sanitized,
                preferredStyle: .alert
            )

            if error.isReportable,
               Config.shared.loggerDelegate?.reportsErrorsAutomatically == false {
                let reportAction = UIAlertAction(
                    title: sendErrorReportButtonTitle.sanitized,
                    style: .default
                ) { _ in
                    Config.shared.reportDelegate?.fileReport(self.error)
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

            Config.shared.presentationDelegate?.present(alertController)
        }

        // MARK: - Translate

        private func translate(_ keys: [TranslationOptionKey]) async -> Result<ErrorAlert, Error> {
            let translator = Config.shared.translationDelegate ?? TranslationService.shared

            var uniqueKeys = [TranslationOptionKey]()
            for key in keys where !uniqueKeys.contains(key) {
                uniqueKeys.append(key)
            }

            guard !uniqueKeys.isEmpty else { return .success(self) }

            let getTranslationsResult = await translator.getTranslations(
                translationInputs(for: uniqueKeys),
                languagePair: .init(
                    from: Config.shared.sourceLanguageCode,
                    to: Config.shared.targetLanguageCode
                ),
                hud: Config.shared.translationHUDConfig,
                timeout: Config.shared.translationTimeoutConfig
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
                return .failure(.translationFailed(error.localizedDescription))
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

            var uniqueInputs = [TranslationInput]()
            for input in inputs where !uniqueInputs.contains(input) {
                uniqueInputs.append(input)
            }

            return uniqueInputs.filter { $0.value != Constants.defaultActionTitle }
        }
    }
}
