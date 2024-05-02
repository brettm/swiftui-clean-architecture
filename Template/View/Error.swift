//
//  Error.swift
//  Template
//
//  Created by Brett Meader on 29/04/2024.
//

import SwiftUI
import ItemsAPIClient

extension ApplicationError {
    var bgColor: Color {
        switch self {
        case .unknown(_):
            return .yellow
        case .network(_):
            return .blue
        case .generic(_):
            return .purple
        }
    }
}

extension ApplicationError {
    static func fromError(_ error: Error) -> ApplicationError {
        if let apiError = error as? APIError {
            return ApplicationError.network(apiError)
        }
        if let localisedError = error as? LocalizedError {
            return ApplicationError.generic(error)
        }
        return ApplicationError.unknown(error)
    }
}

@Observable
final class ErrorHandler: Sendable {
    
    @MainActor
    private(set) var wrapper: ErrorWrapper?
    
    func handleError(error: Error, guidance: String? = nil, retry: (@Sendable () async -> Void)? = nil) async {
        await MainActor.run {
            wrapper = ErrorWrapper(error: ApplicationError.fromError(error))
            wrapper!.retryTask = { [weak self] in
                self?.wrapper = nil
                await retry?()
            }
            wrapper!.dismissTask = { [weak self] in
                Task{ @MainActor in
                    self?.wrapper = nil
            } }
            wrapper!.guidance = guidance
        }
    }
    
    func clearError() async {
        await MainActor.run {
            wrapper = nil
        }
    }
}

struct ErrorHandlerViewModifier: ViewModifier {
    let errorHandler: ErrorHandler
    func body(content: Content) -> some View {
        content
            .environment(errorHandler)
            .sheet(isPresented: Binding(
                get: { errorHandler.wrapper != nil },
                set: { presented,_ in
                    if !presented {
                        Task { await errorHandler.clearError() }
                    }
                }
            ), content: {
                ErrorView(wrapper: errorHandler.wrapper!)
            })
    }
}

extension View {
    func errorHandler(_ errorHandler: ErrorHandler) -> some View {
        modifier(ErrorHandlerViewModifier(errorHandler: errorHandler))
    }
}

struct ErrorView: View {
    let wrapper: ErrorWrapper
    @State private var isRetrying: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                Text(wrapper.error.localizedDescription)
                Spacer()
                if let guidance = wrapper.guidance {
                    Text(guidance)
                    Spacer()
                }
                if let retryTask = wrapper.retryTask {
                    Button(action: {
                        isRetrying.toggle()
                        Task {
                            await retryTask()
                            isRetrying.toggle()
                        }
                    }, label: {
                        ZStack {
                            ProgressView()
                                .opacity(isRetrying ? 0.8 : 0.0)
                            Text("Try Again")
                        }
                    })
                        .disabled(isRetrying)
                    Spacer()
                }
            }
            .padding()
            .toolbar {
                if let dismissTask = wrapper.dismissTask {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Dismiss") {
                            dismissTask()
                        }
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
    }
}


#Preview {
    let wrapper = ErrorWrapper(id: UUID(), error: ApplicationError.generic(nil))
    return ErrorView(wrapper: wrapper)
}
