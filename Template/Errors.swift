//
//  Errors.swift
//  Template
//
//  Created by Brett Meader on 29/04/2024.
//

import Foundation

enum ApplicationError: LocalizedError {
    case unknown(Error?)
    case network(Error?)
    case generic(Error?)
    
    var errorDescription: String? {
        switch self {
        case .unknown(let underlyingError):
            return String(localized: " An unknown error occurred (\(underlyingError?.localizedDescription ?? "‼️"))")
        case .network(let underlyingError):
            return String(localized: "A network error occurred (\(underlyingError?.localizedDescription ?? "‼️"))")
        case .generic(let underlyingError):
            return String(localized: "A general error occurred (\(underlyingError?.localizedDescription ?? "‼️"))")
        }
    }
}

struct ErrorWrapper: Identifiable {
    var id: UUID = .init()
    var error: ApplicationError
    var guidance: String?
    var retryTask: (() async -> Void)?
    var dismissTask: (() -> Void)?
}
