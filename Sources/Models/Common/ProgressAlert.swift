//
//  ProgressAlert.swift
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
    /// An alert that displays the progress of a long-running
    /// operation.
    ///
    /// Use `ProgressAlert` to present an alert with an embedded
    /// progress bar. Provide an asynchronous sequence of completion
    /// fractions to drive the bar automatically – the alert dismisses
    /// itself when the sequence finishes and rethrows any error it
    /// produces:
    ///
    /// ```swift
    /// let alert = AKProgressAlert(
    ///     title: "Uploading Photo",
    ///     message: "Your photo is being uploaded.",
    ///     cancelButtonTitle: "Cancel"
    /// )
    ///
    /// try await alert.present(
    ///     observing: transferProgress.map(\.fractionCompleted)
    /// )
    /// ```
    ///
    /// When you provide a cancel button title, tapping the button
    /// cancels the observed operation and
    /// ``present(observing:translating:)`` throws a
    /// `CancellationError`. Omit the title to present an alert that
    /// can be dismissed only programmatically.
    ///
    /// You can also drive the progress bar manually. Call
    /// ``present(translating:)`` to display the alert,
    /// ``updateProgress(_:)`` to advance the bar, and ``dismiss()``
    /// when your work completes:
    ///
    /// ```swift
    /// let alert = AKProgressAlert(message: "Processing…")
    ///
    /// await alert.present()
    /// alert.updateProgress(0.5)
    /// alert.dismiss()
    /// ```
    ///
    /// By default, both presentation methods translate the alert's
    /// title, message, and cancel button title into the configured
    /// target language before presentation. To present without
    /// translation, pass an empty array.
    ///
    /// - Important: `UIAlertController` provides no supported API for
    ///   embedding accessory views. `ProgressAlert` reserves space
    ///   beneath the alert's message and positions a `UIProgressView`
    ///   within it using layout metrics tuned to the current alert
    ///   design. Verify the layout when adopting a new major OS
    ///   release.
    @MainActor
    final class ProgressAlert {
        // MARK: - Types

        private struct PresentationContent {
            let cancelButtonTitle: String?
            let message: String
            let title: String?
        }

        // MARK: - Properties

        private let cancelButtonStyle: ActionStyle
        private let cancelButtonTitle: String?
        private let message: String
        private let title: String?

        private var messageAttributes: AttributedStringConfig?
        private var observationTask: Task<Void, Never>?
        private var titleAttributes: AttributedStringConfig?
        private var windowDidBecomeHiddenObserver: NSObjectProtocol?
        private var _onCancel: (@MainActor () -> Void)?

        private weak var observedAlertControllerWindow: UIWindow?
        private weak var presentedAlertController: UIAlertController?
        private weak var progressView: UIProgressView?

        // MARK: - Computed Properties

        private var presentationContent: PresentationContent {
            .init(
                cancelButtonTitle: cancelButtonTitle,
                message: message,
                title: title
            )
        }

        // MARK: - Object Lifecycle

        /// Creates a progress alert with the specified title, message,
        /// and cancel button configuration.
        ///
        /// - Parameters:
        ///   - title: The title of the alert. The default is `nil`.
        ///   - message: The descriptive message of the alert.
        ///   - cancelButtonTitle: The title of the cancel button, or
        ///     `nil` to omit the cancel button. The default is `nil`.
        ///   - cancelButtonStyle: The style of the cancel button. The
        ///     default is ``ActionStyle/cancel``.
        public init(
            title: String? = nil,
            message: String,
            cancelButtonTitle: String? = nil,
            cancelButtonStyle: ActionStyle = .cancel
        ) {
            self.cancelButtonStyle = cancelButtonStyle
            self.cancelButtonTitle = cancelButtonTitle
            self.message = message
            self.title = title
        }

        @MainActor
        deinit {
            observationTask?.cancel()
            cleanUp()
        }

        // MARK: - Dismiss

        /// Dismisses the alert.
        ///
        /// Call this method to dismiss an alert presented with
        /// ``present(translating:)`` once your work completes. Alerts
        /// presented with ``present(observing:translating:)`` dismiss
        /// themselves automatically when the observed operation
        /// completes.
        public func dismiss() {
            presentedAlertController?.dismiss(animated: true)
            cleanUp()
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

        // MARK: - On Cancel

        /// Registers a callback that is invoked when the user taps
        /// the alert's cancel button.
        ///
        /// Call this method before presenting the alert. The callback
        /// is released when the alert is dismissed.
        ///
        /// - Parameter perform: The closure to call when the user
        ///   cancels.
        public func onCancel(
            _ perform: @escaping @MainActor () -> Void
        ) {
            _onCancel = perform
        }

        // MARK: - Set Attributed Strings

        /// Sets the attributed string configuration for the alert's
        /// message.
        ///
        /// Call this method before presenting the alert to customize
        /// the appearance of the message text.
        ///
        /// - Parameter messageAttributes: The attributed string
        ///   configuration to apply to the message.
        public func setMessageAttributes(
            _ messageAttributes: AttributedStringConfig
        ) {
            self.messageAttributes = messageAttributes
        }

        /// Sets the attributed string configuration for the alert's
        /// title.
        ///
        /// Call this method before presenting the alert to customize
        /// the appearance of the title text.
        ///
        /// - Parameter titleAttributes: The attributed string
        ///   configuration to apply to the title.
        public func setTitleAttributes(
            _ titleAttributes: AttributedStringConfig
        ) {
            self.titleAttributes = titleAttributes
        }

        // MARK: - Present

        /// Presents the alert and drives its progress bar with the
        /// values of the given asynchronous sequence, suspending
        /// until the observed operation completes.
        ///
        /// Each element of `progress` is a completion fraction in the
        /// range `0.0` through `1.0`; values outside the range are
        /// clamped. When the sequence finishes, the alert dismisses
        /// itself and this method returns. When the sequence throws,
        /// the alert dismisses itself and this method rethrows the
        /// error.
        ///
        /// If the alert includes a cancel button, tapping it cancels
        /// the task observing the sequence and this method throws a
        /// `CancellationError`. Cancellation propagates to the
        /// observed operation when its underlying sequence supports
        /// it.
        ///
        /// If the alert is dismissed out of band – for example, when
        /// the presenting view controller is torn down – the observed
        /// operation continues and this method resumes when it
        /// completes.
        ///
        /// This method translates the alert's content before
        /// presentation according to the specified keys. Each key
        /// identifies a part of the alert to translate. To skip
        /// translation, pass an empty array.
        ///
        /// - Parameters:
        ///   - progress: An asynchronous sequence of completion
        ///     fractions that drives the alert's progress bar.
        ///   - keys: The parts of the alert to translate. The default
        ///     includes all translatable content.
        ///
        /// - Throws: The error produced by `progress`, or
        ///   `CancellationError` if the user cancels.
        public func present(
            observing progress: some AsyncSequence<Double, some Swift.Error>,
            translating keys: [TranslationOptionKey] = [
                .cancelButtonTitle,
                .message,
                .title,
            ]
        ) async throws {
            try await present(
                observing: progress,
                content: resolvedContent(translating: keys)
            ).get()
        }

        /// Presents the alert and returns once it is presented.
        ///
        /// Unlike other AlertKit alert types, this method does not
        /// suspend until the alert is dismissed. After presentation,
        /// advance the progress bar with ``updateProgress(_:)`` and
        /// dismiss the alert with ``dismiss()`` when your work
        /// completes.
        ///
        /// This method translates the alert's content before
        /// presentation according to the specified keys. Each key
        /// identifies a part of the alert to translate. To skip
        /// translation, pass an empty array.
        ///
        /// - Parameter keys: The parts of the alert to translate. The
        ///   default includes all translatable content.
        public func present(
            translating keys: [TranslationOptionKey] = [
                .cancelButtonTitle,
                .message,
                .title,
            ]
        ) async {
            await present(
                with: resolvedContent(translating: keys)
            )
        }

        /// `Swift.Error` requires explicit qualification here, as
        /// ``AlertKit/Error`` shadows it within this namespace.
        private func present(
            observing progress: some AsyncSequence<Double, some Swift.Error>,
            content: PresentationContent
        ) async -> Result<Void, any Swift.Error> {
            await withCheckedContinuation { continuation in
                let continuation = ContinuationGuard(
                    continuation,
                    fallbackValue: .failure(CancellationError())
                )

                present(with: content) {
                    continuation.resume(returning: .failure(CancellationError()))
                }

                observationTask = Task { @MainActor [weak self] in
                    do {
                        for try await fractionCompleted in progress {
                            try Task.checkCancellation()
                            self?.updateProgress(fractionCompleted)
                        }

                        try Task.checkCancellation()

                        self?.updateProgress(1)
                        self?.dismiss()
                        continuation.resume(returning: .success(()))
                    } catch {
                        self?.dismiss()
                        continuation.resume(returning: .failure(error))
                    }
                }
            }
        }

        private func present(
            with content: PresentationContent,
            onCancelTap: (@MainActor () -> Void)? = nil
        ) {
            let alertController = UIAlertController(
                title: content.title?.sanitized,
                message: content.message.sanitized,
                preferredStyle: .alert
            )

            if let cancelButtonTitle = content.cancelButtonTitle {
                let cancelAction = UIAlertAction(
                    title: cancelButtonTitle.sanitized,
                    style: cancelButtonStyle.uiAlertStyle
                ) { [weak self] _ in
                    Task { @MainActor [weak self] in
                        self?.handleCancelActionTap()
                        onCancelTap?()
                    }
                }

                alertController.addAction(cancelAction)
            }

            progressView = alertController.addProgressView(
                hasCancelAction: content.cancelButtonTitle != nil
            )

            alertController.applyAttributedStrings(
                messageAttributes: messageAttributes,
                titleAttributes: titleAttributes
            )

            presentedAlertController = alertController
            AlertKit.config.presentationDelegate?.present(alertController)
            observeAlertControllerWindow(of: alertController)
        }

        // MARK: - Translate

        private func resolvedContent(
            translating keys: [TranslationOptionKey]
        ) async -> PresentationContent {
            await AlertKit.presentWithTranslation(
                shouldTranslate: !keys.isEmpty,
                presentDirectly: { presentationContent },
                translate: { try await translate(keys) },
                presentTranslated: { $0 },
                sender: self
            )
        }

        private func translate(
            _ keys: [TranslationOptionKey]
        ) async throws -> PresentationContent {
            let uniqueKeys = keys.unique
            guard !uniqueKeys.isEmpty else { return presentationContent }

            let translations = try await AlertKit.getTranslations(
                for: translationInputs(for: uniqueKeys)
            )

            return .init(
                cancelButtonTitle: cancelButtonTitle.map { translations.firstOutput(matching: $0) },
                message: translations.firstOutput(matching: message),
                title: title.map { translations.firstOutput(matching: $0) }
            )
        }

        // MARK: - Translation Inputs

        private func translationInputs(
            for optionKeys: [TranslationOptionKey]
        ) -> [TranslationInput] {
            var inputs = [TranslationInput]()
            for key in optionKeys {
                switch key {
                case .cancelButtonTitle:
                    guard let cancelButtonTitle else { continue }
                    inputs.append(.init(cancelButtonTitle))

                case .message:
                    inputs.append(.init(message))

                case .title:
                    guard let title else { continue }
                    inputs.append(.init(title))
                }
            }

            return inputs.nonDefaultUnique
        }

        // MARK: - Update Progress

        /// Updates the alert's progress bar to the specified
        /// completion fraction.
        ///
        /// This method has no effect until the alert is presented.
        ///
        /// - Parameter fractionCompleted: The fraction of the
        ///   operation that has completed, in the range `0.0` through
        ///   `1.0`. Values outside the range are clamped.
        public func updateProgress(_ fractionCompleted: Double) {
            let fractionCompleted = min(
                max(fractionCompleted, 0),
                1
            )

            progressView?.setProgress(
                Float(fractionCompleted),
                animated: true
            )
        }

        // MARK: - Auxiliary

        private func cleanUp() {
            if let windowDidBecomeHiddenObserver {
                NotificationCenter.default.removeObserver(windowDidBecomeHiddenObserver)
                self.windowDidBecomeHiddenObserver = nil
            }

            observedAlertControllerWindow = nil
            presentedAlertController = nil
            progressView = nil
            _onCancel = nil
        }

        private func handleCancelActionTap() {
            observationTask?.cancel()
            observationTask = nil
            _onCancel?()
            cleanUp()
        }

        private func observeAlertControllerWindow(of alertController: UIAlertController) {
            DispatchQueue.main.async { [weak alertController, weak self] in
                guard let self,
                      let window = alertController?.view.window else { return }

                observedAlertControllerWindow = window
                windowDidBecomeHiddenObserver = NotificationCenter.default.addObserver(
                    forName: UIWindow.didBecomeHiddenNotification,
                    object: window,
                    queue: .main
                ) { [weak self] _ in
                    Task { @MainActor [weak self] in
                        self?.cleanUp()
                    }
                }
            }
        }
    }
}
