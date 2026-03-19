import Combine
import SwiftUI

struct LoginWithEmailScreenCoordinatorParameters {
    let authenticationService: AuthenticationServiceProtocol
    let appSettings: AppSettings
    let userIndicatorController: UserIndicatorControllerProtocol
}

enum LoginWithEmailScreenCoordinatorAction {
    case continueWithOIDC(data: OIDCAuthorizationDataProxy, window: UIWindow)
    case continueWithPassword(loginHint: String)
}

final class LoginWithEmailScreenCoordinator: CoordinatorProtocol {
    private let parameters: LoginWithEmailScreenCoordinatorParameters
    private let viewModel: LoginWithEmailScreenViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()
 
    private let actionsSubject: PassthroughSubject<LoginWithEmailScreenCoordinatorAction, Never> = .init()
    var actionsPublisher: AnyPublisher<LoginWithEmailScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(parameters: LoginWithEmailScreenCoordinatorParameters) {
        self.parameters = parameters
        
        viewModel = LoginWithEmailScreenViewModel(authenticationService: parameters.authenticationService,
                                                  appSettings: parameters.appSettings,
                                                  userIndicatorController: parameters.userIndicatorController)
    }
    
    func start() {
        viewModel.actionsPublisher.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .continueWithOIDC(data: let data, window: let window):
                actionsSubject.send(.continueWithOIDC(data: data, window: window))
            case .continueWithPassword(let loginHint):
                actionsSubject.send(.continueWithPassword(loginHint: loginHint))
            }
        }
        .store(in: &cancellables)
    }
        
    func toPresentable() -> AnyView {
        AnyView(LoginWithEmailScreen(context: viewModel.context))
    }
}
