import Foundation
import SwiftUI

/// A public enum representing common application errors with user-friendly descriptions and recovery suggestions.
public enum AppError: LocalizedError {
    case persistence
    case invalidData
    case notFound
    case unknown(underlying: Error)
    
    public var errorDescription: String? {
        switch self {
        case .persistence:
            return NSLocalizedString("A problem occurred while saving or loading data.", comment: "Persistence Error Description")
        case .invalidData:
            return NSLocalizedString("The data received was invalid or corrupted.", comment: "Invalid Data Error Description")
        case .notFound:
            return NSLocalizedString("The requested item was not found.", comment: "Not Found Error Description")
        case .unknown(let underlying):
            return NSLocalizedString("An unknown error occurred: \(underlying.localizedDescription)", comment: "Unknown Error Description")
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .persistence:
            return NSLocalizedString("Please try again or restart the application.", comment: "Persistence Error Recovery")
        case .invalidData:
            return NSLocalizedString("Please verify the data source or contact support.", comment: "Invalid Data Recovery")
        case .notFound:
            return NSLocalizedString("Please check the item identifier and try again.", comment: "Not Found Recovery")
        case .unknown:
            return NSLocalizedString("Please retry or contact support if the problem persists.", comment: "Unknown Error Recovery")
        }
    }
}

/// A final class that manages errors in the app, publishing active errors and logging them.
@MainActor @Observable
public final class ErrorManager {
    
    /// A struct representing an error to display, with a unique ID and user-facing information.
    public struct DisplayError: Identifiable {
        public let id = UUID()
        public let title: String
        public let message: String
        public let recovery: String?
        
        public init(title: String, message: String, recovery: String? = nil) {
            self.title = title
            self.message = message
            self.recovery = recovery
        }
    }
    
    /// The currently active error to present, if any.
    public var activeError: DisplayError?
    
    public init() {}
    
    /// Logs the error to the console in debug builds.
    /// - Parameter error: The error to log.
    public func log(_ error: Error) {
        #if DEBUG
        print("Error logged: \(error.localizedDescription)")
        #endif
    }
    
    /// Handles an error by mapping it to `AppError`, setting the active error, and logging it.
    /// - Parameters:
    ///   - error: The error to handle.
    ///   - context: A string describing the context in which the error occurred.
    public func handle(_ error: Error, context: String) {
        let appError = Self.map(error)
        log(appError)
        let displayError = DisplayError(
            title: NSLocalizedString("Error", comment: "Error Alert Title"),
            message: "\(context):\n\(appError.errorDescription ?? NSLocalizedString("An error occurred.", comment: "Generic error message"))",
            recovery: appError.recoverySuggestion
        )
        activeError = displayError
    }

    /// Presents a custom error message with a title.
    /// - Parameters:
    ///   - message: The error message.
    ///   - title: The error title.
    public func present(message: String, title: String = NSLocalizedString("Error", comment: "Error Alert Title")) {
        activeError = DisplayError(title: title, message: message, recovery: nil)
    }
    
    /// Maps any `Error` to an `AppError` for standardized handling.
    /// - Parameter error: The error to map.
    /// - Returns: A corresponding `AppError`.
    public static func map(_ error: Error) -> AppError {
        // Customize mapping logic as needed.
        // Example basic mapping:
        let nsError = error as NSError
        switch nsError.domain {
        case NSCocoaErrorDomain:
            switch nsError.code {
            case NSFileNoSuchFileError, NSFileReadNoSuchFileError:
                return .notFound
            case NSPersistentStoreSaveError, NSFileWriteNoPermissionError:
                return .persistence
            default:
                return .unknown(underlying: error)
            }
        default:
            return .unknown(underlying: error)
        }
    }
}

public extension View {
    /// Attaches an alert to the view that presents errors from the given `ErrorManager`.
    /// - Parameter manager: The error manager publishing errors.
    /// - Returns: A view with an attached error alert.
    func errorAlert(_ manager: ErrorManager) -> some View {
        let binding = Binding(
            get: { manager.activeError },
            set: { manager.activeError = $0 }
        )
        return alert(item: binding) { displayError in
            Alert(
                title: Text(displayError.title),
                message: Text(displayError.message + (displayError.recovery.map { "\n\n\($0)" } ?? "")),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
