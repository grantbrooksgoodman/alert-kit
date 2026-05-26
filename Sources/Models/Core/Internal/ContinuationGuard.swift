//
//  ContinuationGuard.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

/// Wraps a `CheckedContinuation` to ensure it resumes exactly once.
///
/// If the guard is deallocated before an explicit
/// ``resume(returning:)`` call, the continuation resumes with the
/// provided fallback value. This prevents silent hangs when an alert
/// is dismissed out-of-band – for example, when the presenting view
/// controller is torn down while the alert is still visible.
///
/// All access is expected to occur on the main thread.
@MainActor
final class ContinuationGuard<T: Sendable> {
    // MARK: - Properties

    private let fallbackValue: T
    private let lock = NSRecursiveLock()

    private var continuation: CheckedContinuation<T, Never>?

    // MARK: - Object Lifecycle

    init(
        _ continuation: CheckedContinuation<T, Never>,
        fallbackValue: T
    ) {
        self.continuation = continuation
        self.fallbackValue = fallbackValue
    }

    deinit {
        continuation?.resume(returning: fallbackValue)
    }

    // MARK: - Resume

    func resume(returning value: T) {
        lock.withLock {
            continuation?.resume(returning: value)
            continuation = nil
        }
    }
}
