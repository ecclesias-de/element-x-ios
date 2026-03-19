import Foundation
import SwiftUI

enum LoginWithEmailScreenViewModelAction {
    case continueWithOIDC(data: OIDCAuthorizationDataProxy, window: UIWindow)
    case continueWithPassword(loginHint: String)
}

struct LoginWithEmailScreenViewState: BindableState {
    var isLoading = false
    
    var window: UIWindow?
    
    var bindings: LoginWithEmailScreenViewStateBindings
    
    var canSubmit: Bool {
        !bindings.username.isEmpty && !isLoading
    }
}

struct LoginWithEmailScreenViewStateBindings {
    var username = ""

    var loginWithEmailAlertInfo: AlertInfo<LoginWithEmailScreenAlert>?
    var serverConfirmationScreenAlertInfo: AlertInfo<ServerConfirmationScreenAlert>?
}

enum LoginWithEmailScreenViewAction {
    case next
}

enum LoginWithEmailScreenAlert: Hashable {
    case invalidEmail
    case requestFailed
    case requestNotSuccessfull
    case jsonDecodeFailed
    case baseUrlNotConfigured
}
