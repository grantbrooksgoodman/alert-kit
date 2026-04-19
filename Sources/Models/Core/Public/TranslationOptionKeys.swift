//
//  TranslationOptionKeys.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

// MARK: - ActionSheet

public extension AlertKit.ActionSheet {
    /// A value that identifies a translatable part of an
    /// ``ActionSheet``.
    ///
    /// Pass one or more translation option keys to
    /// ``ActionSheet/present(translating:)`` to control which parts
    /// of the action sheet are translated before presentation.
    enum TranslationOptionKey: Hashable, Sendable {
        /// The action button titles.
        ///
        /// Pass an empty array to translate all actions, or pass a
        /// specific subset of actions to translate only those.
        case actions([AlertKit.Action] = [])

        /// The cancel button's title.
        case cancelButtonTitle

        /// The action sheet's message.
        case message

        /// The action sheet's title.
        case title
    }
}

// MARK: - Alert

public extension AlertKit.Alert {
    /// A value that identifies a translatable part of an ``Alert``.
    ///
    /// Pass one or more translation option keys to
    /// ``Alert/present(translating:)`` to control which parts of
    /// the alert are translated before presentation.
    enum TranslationOptionKey: Hashable, Sendable {
        /// The action button titles.
        ///
        /// Pass an empty array to translate all actions, or pass a
        /// specific subset of actions to translate only those.
        case actions([AlertKit.Action] = [])

        /// The alert's message.
        case message

        /// The alert's title.
        case title
    }
}

// MARK: - ConfirmationAlert

public extension AlertKit.ConfirmationAlert {
    /// A value that identifies a translatable part of a
    /// ``ConfirmationAlert``.
    ///
    /// Pass one or more translation option keys to
    /// ``ConfirmationAlert/present(translating:)`` to control which
    /// parts of the alert are translated before presentation.
    enum TranslationOptionKey: Hashable, Sendable {
        /// The cancel button's title.
        case cancelButtonTitle

        /// The confirm button's title.
        case confirmButtonTitle

        /// The alert's message.
        case message

        /// The alert's title.
        case title
    }
}

// MARK: - ErrorAlert

public extension AlertKit.ErrorAlert {
    /// A value that identifies a translatable part of an
    /// ``ErrorAlert``.
    ///
    /// Pass one or more translation option keys to
    /// ``ErrorAlert/present(translating:)`` to control which parts
    /// of the alert are translated before presentation.
    enum TranslationOptionKey: Hashable, Sendable {
        /// The dismiss button's title.
        case dismissButtonTitle

        /// The error's description text.
        case errorDescription

        /// The send error report button's title.
        case sendErrorReportButtonTitle
    }
}

// MARK: - TextInputAlert

public extension AlertKit.TextInputAlert {
    /// A value that identifies a translatable part of a
    /// ``TextInputAlert``.
    ///
    /// Pass one or more translation option keys to
    /// ``TextInputAlert/present(translating:)`` to control which
    /// parts of the alert are translated before presentation.
    enum TranslationOptionKey: Hashable, Sendable {
        /// The cancel button's title.
        case cancelButtonTitle

        /// The confirm button's title.
        case confirmButtonTitle

        /// The alert's message.
        case message

        /// The text field's placeholder text.
        case placeholderText

        /// The text field's sample text.
        case sampleText

        /// The alert's title.
        case title
    }
}
