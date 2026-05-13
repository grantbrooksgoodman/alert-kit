# AlertKit

A translation-aware alert presentation framework built on `UIAlertController`.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Alert Types](#alert-types)
  - [Alert](#alert)
  - [Action Sheet](#action-sheet)
  - [Confirmation Alert](#confirmation-alert)
  - [Error Alert](#error-alert)
  - [Text Input Alert](#text-input-alert)
- [Actions](#actions)
- [Translation](#translation)
  - [Selective Translation](#selective-translation)
  - [Translation Configuration](#translation-configuration)
- [Customization](#customization)
  - [Attributed Strings](#attributed-strings)
  - [Text Field Configuration](#text-field-configuration)
- [Delegates](#delegates)
- [Type Aliases](#type-aliases)

---

## Overview

AlertKit provides a structured system for presenting alerts in your app. It wraps `UIAlertController` with a set of types designed for specific interaction patterns and adds automatic translation support through a configurable delegate system.

The framework defines five alert types:

| Type | Purpose |
| --- | --- |
| [`Alert`](Sources/Models/Common/Alert.swift) | A general-purpose alert with a title, message, and custom actions |
| [`ActionSheet`](Sources/Models/Common/ActionSheet.swift) | A list of actions presented as a popover (iOS 26+) or from the bottom of the screen (iOS ≤ 18) |
| [`ConfirmationAlert`](Sources/Models/Common/ConfirmationAlert.swift) | A two-button dialog that resolves to a Boolean result |
| [`ErrorAlert`](Sources/Models/Common/ErrorAlert.swift) | An alert that presents an error with optional reporting |
| [`TextInputAlert`](Sources/Models/Common/TextInputAlert.swift) | An alert with a text field that returns the entered string |

All alert types support Swift concurrency with `async`/`await` and translate their content automatically before presentation. You control which parts are translated through each type's [`TranslationOptionKey`](Sources/Models/Core/Public/TranslationOptionKeys.swift), and can skip translation entirely by passing an empty array.

---

## Requirements

| Platform | Minimum Version |
| --- | --- |
| iOS | 17.0 |

---

## Installation

AlertKit is distributed as a Swift package. Add it to your project using [Swift Package Manager](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/).

---

## Getting Started

AlertKit uses a delegate-based architecture. Before presenting alerts, register a [`PresentationDelegate`](Sources/Protocols/PresentationDelegate.swift) to tell AlertKit how to display alert controllers in your app:

```swift
AlertKit.config.registerPresentationDelegate(myDelegate)
```

Your presentation delegate is responsible for presenting each `UIAlertController` on the appropriate view controller. Without a registered presentation delegate, calls to `present(translating:)` on any alert type have no visible effect.

To override the default translation implementation provided by [Translator](https://github.com/grantbrooksgoodman/translator), register a [`TranslationDelegate`](Sources/Protocols/TranslationDelegate.swift):

```swift
AlertKit.config.registerTranslationDelegate(myDelegate)
```

---

## Alert Types

### Alert

[`Alert`](Sources/Models/Common/Alert.swift) presents a standard alert dialog with a title, message, and one or more actions. When you omit the `actions` parameter, the alert displays a single "OK" button with the `cancel` style.

```swift
let alert = AKAlert(
    title: "Remove Item",
    message: "This action cannot be undone.",
    actions: [
        .init("Remove", style: .destructive) {
            removeItem()
        },
        .init("Cancel", style: .cancel) {},
    ]
)

await alert.present()
```

### Action Sheet

[`ActionSheet`](Sources/Models/Common/ActionSheet.swift) presents a list of actions as a popover (iOS 26+) or from the bottom of the screen (iOS ≤ 18). A cancel button is added automatically unless one of the provided actions uses the `cancel` style. You can customize the cancel button's title through the `cancelButtonTitle` parameter.

```swift
let actionSheet = AKActionSheet(
    title: "Share Photo",
    actions: [
        .init("Save to Camera Roll") {
            savePhoto()
        },
        .init("Copy Link") {
            copyLink()
        },
    ]
)

await actionSheet.present()
```

When an `ActionSheet` is created with a `title` but no `message`, the title is displayed in the message position of the underlying `UIAlertController`. This produces a more natural visual layout for title-only action sheets, as `UIAlertController` renders messages with a smaller, lighter font that works better for short descriptive text in this context.

On iOS 26 and later, the action sheet may be presented as a popover. Provide a [`SourceItem`](Sources/Models/Core/Public/ActionSheetSourceItem.swift) to specify the view that the popover anchors to.

### Confirmation Alert

[`ConfirmationAlert`](Sources/Models/Common/ConfirmationAlert.swift) presents a two-button dialog and returns a Boolean value. The method returns `true` when the user taps confirm and `false` when they tap cancel.

```swift
let confirmed = await AKConfirmationAlert(
    title: "Remove Item",
    message: "This action cannot be undone."
).present()

if confirmed {
    removeItem()
}
```

You can customize the button titles and styles:

```swift
let confirmationAlert = AKConfirmationAlert(
    message: "Discard your changes?",
    cancelButtonTitle: "Keep Editing",
    confirmButtonTitle: "Discard",
    confirmButtonStyle: .destructive
)

if await confirmationAlert.present() {
    discardChanges()
}
```

### Error Alert

[`ErrorAlert`](Sources/Models/Common/ErrorAlert.swift) presents an error that conforms to the [`Errorable`](Sources/Protocols/Errorable.swift) protocol:

```swift
await AKErrorAlert(error).present()
```

When the error's `isReportable` property is `true`, a [`ReportDelegate`](Sources/Protocols/ReportDelegate.swift) has been configured, and the logger delegate does not report errors automatically, the alert includes a "Send Error Report" button. Tapping this button files a report through the registered [`ReportDelegate`](Sources/Protocols/ReportDelegate.swift). Otherwise, the alert displays the error description as the title with the error identifier in the message body.

Conform your error types to [`Errorable`](Sources/Protocols/Errorable.swift) to use them with `ErrorAlert`:

```swift
struct MyError: AlertKit.Errorable {
    let id: String
    let isReportable: Bool
    let metadataArray: [Any]
    let userInfo: [String: Any]?
    var description: String
}
```

The `description` property is declared with a setter because AlertKit may replace it with a translated value before presentation.

### Text Input Alert

[`TextInputAlert`](Sources/Models/Common/TextInputAlert.swift) presents an alert with a single text field. The `present()` method returns the entered text when the user taps confirm, or `nil` when they cancel.

```swift
let textInputAlert = AKTextInputAlert(
    title: "Rename",
    message: "Enter a new name for this item.",
    attributes: .init(
        capitalizationType: .words,
        placeholderText: "Item name"
    )
)

if let name = await textInputAlert.present() {
    rename(to: name)
}
```

To respond to changes as the user types, register a callback with `onTextFieldChange(_:)` before presenting:

```swift
textInputAlert.onTextFieldChange { textField in
    guard let text = textField?.text else { return }
    // Respond to changes in the text field.
}
```

The observer is automatically removed when the alert is dismissed.

---

## Actions

An [`Action`](Sources/Models/Core/Public/Action.swift) pairs a button title with a closure that executes when the user taps the corresponding button. You specify the visual style using [`ActionStyle`](Sources/Models/Core/Public/ActionStyle.swift):

```swift
let action = AKAction("Delete", style: .destructive) {
    deleteItem()
}
```

Pass one or more actions to an [`Alert`](Sources/Models/Common/Alert.swift) or [`ActionSheet`](Sources/Models/Common/ActionSheet.swift) at initialization.

> **Note:** Each `Action` instance carries a unique internal identifier. Two actions with identical titles and styles are not considered equal if they are different instances. When using `.actions([...])` in a `TranslationOptionKey` to translate specific actions, pass the exact `Action` instances used to create the alert – newly constructed actions with the same properties will not match.

The available styles are:

| Style | Description |
| --- | --- |
| `cancel` | Dismisses the alert without changes. |
| `default` | The default button style. |
| `destructive` | Indicates the action might change or delete data. |
| `preferred` | The alert's preferred action, given visual emphasis. |
| `destructivePreferred` | A destructive action that is also the alert's preferred action. |

You can enable or disable actions on a presented alert by calling `disableAction(at:)` or `enableAction(at:)` with the zero-based index of the action.

---

## Translation

By default, every alert translates its content into the configured target language before presentation. The `present(translating:)` method accepts an array of [`TranslationOptionKey`](Sources/Models/Core/Public/TranslationOptionKeys.swift) values that identify which parts of the alert to translate.

Each alert type defines its own `TranslationOptionKey` enum. For example, `Alert.TranslationOptionKey` provides `.title`, `.message`, and `.actions()`, while `TextInputAlert.TranslationOptionKey` adds `.placeholderText` and `.sampleText`.

### Selective Translation

To present without translation, pass an empty array:

```swift
await alert.present(translating: [])
```

To translate only specific parts of the alert:

```swift
await alert.present(translating: [.title, .message])
```

For alert types with actions, the `.actions()` case accepts an optional array to translate only specific actions. Pass an empty array to translate all actions.

### Sanitization

AlertKit removes three sentinel characters from all user-facing strings before display: `⌘` (U+2318), `⁂` (U+2042), and `※` (U+203B). These characters serve as internal tokens for the translation system – they are used as delimiters during translation tokenization and must not appear in the final output. Any occurrences in titles, messages, button labels, or translated text are stripped automatically.

### Translation Configuration

Configure translation behavior through `AlertKit.config`:

| Setting | Method | Default |
| --- | --- | --- |
| Source language | `overrideSourceLanguageCode(_:)` | `"en"` |
| Target language | `overrideTargetLanguageCode(_:)` | System language |
| HUD appearance | `overrideTranslationHUDConfig(_:)` | 2-second delay, modal |
| Timeout behavior | `overrideTranslationTimeoutConfig(_:)` | 10 seconds, falls back to originals |

A [`HUDConfig`](Sources/Models/Core/Public/HUDConfig.swift) controls when and how a heads-up display appears during translation:

```swift
AlertKit.config.overrideTranslationHUDConfig(
    .init(appearsAfter: .seconds(1), isModal: true)
)
```

A [`TranslationTimeoutConfig`](Sources/Models/Core/Public/TranslationTimeoutConfig.swift) controls the maximum wait duration and failure behavior. When `returnsInputsOnFailure` is `true`, a timed-out translation falls back to the original untranslated strings rather than presenting an error:

```swift
AlertKit.config.overrideTranslationTimeoutConfig(
    .init(.seconds(5), returnsInputsOnFailure: true)
)
```

### Translation Timeout Control

If a custom translation delegate may take longer than expected, callers can impose a timeout by cancelling the presenting task. When the task is cancelled during translation, AlertKit logs the cancellation and presents the alert with its original untranslated content:

```swift
let task = Task {
    await alert.present()
}

Task {
    try? await Task.sleep(for: .seconds(5))
    task.cancel()  // Falls back to untranslated presentation
}

await task.value
```

Custom `TranslationDelegate` implementations should check `Task.isCancelled` during long-running operations and return early when appropriate.

---

## Customization

### Attributed Strings

Use [`AttributedStringConfig`](Sources/Models/Core/Public/AttributedStringConfig.swift) to customize the appearance of an alert's title or message. Call `setTitleAttributes(_:)` or `setMessageAttributes(_:)` before presenting:

```swift
let alert = AKAlert(message: "Operation complete.")

alert.setMessageAttributes(
    .init([.font: UIFont.boldSystemFont(ofSize: 17)])
)

await alert.present()
```

To apply different attributes to specific substrings, provide secondary attributes using `StringAttributes`:

```swift
let config = AlertKit.AttributedStringConfig(
    [.font: UIFont.systemFont(ofSize: 15)],
    secondaryAttributes: [
        .init(
            [.foregroundColor: UIColor.red],
            stringRanges: ["important"]
        ),
    ]
)
```

Attributed string customization is available on [`Alert`](Sources/Models/Common/Alert.swift), [`ActionSheet`](Sources/Models/Common/ActionSheet.swift), [`ConfirmationAlert`](Sources/Models/Common/ConfirmationAlert.swift), and [`TextInputAlert`](Sources/Models/Common/TextInputAlert.swift).

### Text Field Configuration

Use [`TextFieldAttributes`](Sources/Models/Core/Public/TextFieldAttributes.swift) to configure the text field in a [`TextInputAlert`](Sources/Models/Common/TextInputAlert.swift). You can specify the keyboard type, autocapitalization, autocorrection, placeholder text, sample text, secure entry, and text alignment:

```swift
let attributes = AlertKit.TextFieldAttributes(
    capitalizationType: .words,
    keyboardType: .emailAddress,
    placeholderText: "Email"
)

let textInputAlert = AKTextInputAlert(
    message: "Enter your email.",
    attributes: attributes
)
```

When you omit parameters, the text field uses sensible defaults: sentence capitalization, the standard keyboard, and center-aligned text.

---

## Delegates

AlertKit defines five delegate protocols.

| Delegate | Purpose |
| --- | --- |
| [`InspectionDelegate`](Sources/Protocols/InspectionDelegate.swift) | Resolves views used as popover anchors in action sheets |
| [`LoggerDelegate`](Sources/Protocols/LoggerDelegate.swift) | Receives diagnostic log messages from AlertKit operations |
| [`PresentationDelegate`](Sources/Protocols/PresentationDelegate.swift) | Presents alert controllers on the appropriate view controller |
| [`ReportDelegate`](Sources/Protocols/ReportDelegate.swift) | Files error reports when the user taps "Send Error Report" |
| [`TranslationDelegate`](Sources/Protocols/TranslationDelegate.swift) | Provides translations for alert content |

Register each through `AlertKit.config`:

```swift
AlertKit.config.registerInspectionDelegate(myInspectionDelegate)
AlertKit.config.registerLoggerDelegate(myLoggerDelegate)
AlertKit.config.registerPresentationDelegate(myPresentationDelegate)
AlertKit.config.registerReportDelegate(myReportDelegate)
AlertKit.config.registerTranslationDelegate(myTranslationDelegate)
```

The [`LoggerDelegate`](Sources/Protocols/LoggerDelegate.swift) also controls how [`ErrorAlert`](Sources/Models/Common/ErrorAlert.swift) handles reportable errors. When its `reportsErrorsAutomatically` property is `true`, the alert omits the "Send Error Report" button and instead displays the error identifier in the message body.

> **Note:** [`PresentationDelegate`](Sources/Protocols/PresentationDelegate.swift) is required for alerts to appear. The remaining delegates are optional and enable additional functionality when registered.

---

## Type Aliases

AlertKit provides convenience aliases for its public types:

| Alias | Type |
| --- | --- |
| `AKAction` | `AlertKit.Action` |
| `AKActionSheet` | `AlertKit.ActionSheet` |
| `AKAlert` | `AlertKit.Alert` |
| `AKConfirmationAlert` | `AlertKit.ConfirmationAlert` |
| `AKErrorAlert` | `AlertKit.ErrorAlert` |
| `AKTextInputAlert` | `AlertKit.TextInputAlert` |

---

&copy; NEOTechnica Corporation. All rights reserved.
