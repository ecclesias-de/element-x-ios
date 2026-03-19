import Combine
import SwiftUI

typealias LoginWithEmailScreenViewModelType = StateStoreViewModelV2<LoginWithEmailScreenViewState, LoginWithEmailScreenViewAction>

struct HomerServer: Codable {
    let baseUrl: String
    
    enum CodingKeys: String, CodingKey {
        case baseUrl = "base_url"
    }
}

struct WellKnown: Codable {
    let homerServer: HomerServer?
    let ecclesiasChatBaseUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case homerServer = "m.homeserver"
        case ecclesiasChatBaseUrl = "ecclesiasChat.baseUrl"
    }
}

class LoginWithEmailScreenViewModel: LoginWithEmailScreenViewModelType, LoginWithEmailScreenViewModelProtocol {
    let authenticationService: AuthenticationServiceProtocol
    let appSettings: AppSettings
    let userIndicatorController: UserIndicatorControllerProtocol
    
    private let actionsSubject: PassthroughSubject<LoginWithEmailScreenViewModelAction, Never> = .init()
    
    var actionsPublisher: AnyPublisher<LoginWithEmailScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(authenticationService: AuthenticationServiceProtocol,
         appSettings: AppSettings,
         userIndicatorController: UserIndicatorControllerProtocol) {
        self.authenticationService = authenticationService
        self.appSettings = appSettings
        self.userIndicatorController = userIndicatorController
        
        super.init(initialViewState: LoginWithEmailScreenViewState(bindings: LoginWithEmailScreenViewStateBindings()))
    }
    
    // MARK: - Public
    
    override func process(viewAction: LoginWithEmailScreenViewAction) {
        switch viewAction {
        case .next:
            startLoading()
            Task { await confirmServer() }
        }
    }
    
    private func confirmServer() async {
        let email = state.bindings.username
        
        defer { stopLoading() }
        startLoading()
        
        let emailParts = email.components(separatedBy: "@")
        
        if emailParts.count != 2 {
            displayLoginWithEmailScreenError(.invalidEmail)
            return
        }
        
        var homeserverAddress = ""
        
        let url = URL(string: String(format: "https://%@/.well-known/matrix/client", emailParts[1]))!
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    displayLoginWithEmailScreenError(.requestNotSuccessfull)
                    return
                }
            } else {
                displayLoginWithEmailScreenError(.requestFailed)
                return
            }
            
            let wellKnown = try JSONDecoder().decode(WellKnown.self, from: data)
            
            if wellKnown.homerServer != nil {
                homeserverAddress = wellKnown.homerServer!.baseUrl
            } else if wellKnown.ecclesiasChatBaseUrl != nil {
                homeserverAddress = wellKnown.ecclesiasChatBaseUrl!
            } else {
                displayLoginWithEmailScreenError(.baseUrlNotConfigured)
                return
            }

        } catch DecodingError.dataCorrupted {
            displayLoginWithEmailScreenError(.jsonDecodeFailed)
            return
        } catch {
            MXLog.info(error)
            displayLoginWithEmailScreenError(.requestFailed)
            return
        }
                
        switch await authenticationService.configure(for: homeserverAddress, flow: .login) {
        case .success:
            await fetchLoginURLIfNeededAndContinue(email: email)
        case .failure(let error):
            switch error {
            case .invalidServer, .invalidHomeserverAddress:
                displayServerConfirmationScreenError(.homeserverNotFound)
            case .invalidWellKnown(let error):
                displayServerConfirmationScreenError(.invalidWellKnown(error))
            case .slidingSyncNotAvailable:
                displayServerConfirmationScreenError(.slidingSync)
            case .loginNotSupported:
                displayServerConfirmationScreenError(.login)
            case .registrationNotSupported:
                displayServerConfirmationScreenError(.registration)
            case .elementProRequired(let serverName):
                displayServerConfirmationScreenError(.elementProRequired(serverName: serverName))
            default:
                displayServerConfirmationScreenError(.unknownError)
            }
        }
    }
    
    private func fetchLoginURLIfNeededAndContinue(email: String) async {
        guard authenticationService.homeserver.value.loginMode.supportsOIDCFlow else {
            actionsSubject.send(.continueWithPassword(loginHint: email))
            return
        }
        
        guard let window = state.window else {
            displayServerConfirmationScreenError(.unknownError)
            return
        }
        
        startLoading() // Uses the same ID, so no need to worry if the indicator already exists
        defer { stopLoading() }
        
        switch await authenticationService.urlForOIDCLogin(loginHint: nil) {
        case .success(let oidcData):
            actionsSubject.send(.continueWithOIDC(data: oidcData, window: window))
        case .failure:
            displayServerConfirmationScreenError(.unknownError)
        }
    }
    
    private let loadingIndicatorID = "\(LoginWithEmailScreenViewModel.self)-Loading"
    
    private func startLoading() {
        userIndicatorController.submitIndicator(UserIndicator(id: loadingIndicatorID,
                                                              type: .modal,
                                                              title: L10n.commonLoading,
                                                              persistent: true))
    }
    
    private func stopLoading() {
        userIndicatorController.retractIndicatorWithId(loadingIndicatorID)
    }
    
    private func displayLoginWithEmailScreenError(_ type: LoginWithEmailScreenAlert) {
        switch type {
        case .invalidEmail:
            state.bindings.loginWithEmailAlertInfo = AlertInfo(id: .invalidEmail,
                                                               title: L10n.loginWithEmailScreenErrorEmailInvalidTitle)
        case .jsonDecodeFailed:
            state.bindings.loginWithEmailAlertInfo = AlertInfo(id: .jsonDecodeFailed,
                                                               title: L10n.loginWithEmailScreenErrorNotConfiguredTitle,
                                                               message: L10n.loginWithEmailScreenErrorJsonDecodeFailed)
        case .requestFailed:
            state.bindings.loginWithEmailAlertInfo = AlertInfo(id: .requestFailed,
                                                               title: L10n.loginWithEmailScreenErrorNotConfiguredTitle,
                                                               message: L10n.loginWithEmailScreenErrorRequestFailed)
        case .requestNotSuccessfull:
            state.bindings.loginWithEmailAlertInfo = AlertInfo(id: .requestNotSuccessfull,
                                                               title: L10n.loginWithEmailScreenErrorNotConfiguredTitle,
                                                               message: L10n.loginWithEmailScreenErrorRequestNotSucessfull)
        case .baseUrlNotConfigured:
            state.bindings.loginWithEmailAlertInfo = AlertInfo(id: .requestFailed,
                                                               title: L10n.loginWithEmailScreenErrorNotConfiguredTitle,
                                                               message: L10n.loginWithEmailScreenErrorBaseUrlNotConfigured)
        }
    }
    
    private func displayServerConfirmationScreenError(_ type: ServerConfirmationScreenAlert) {
        state.bindings.serverConfirmationScreenAlertInfo = errorToAlertInfo(type, elementProAppStoreURL: appSettings.elementProAppStoreURL)
    }
}
