import Compound
import SwiftUI

struct LoginWithEmailScreen: View {
    @FocusState private var isUsernameFocused: Bool
    
    @Bindable var context: LoginWithEmailScreenViewModel.Context
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.top, UIConstants.titleTopPaddingToNavigationBar)
                    .padding(.bottom, 32)
                
                loginForm
            }
            .readableFrame()
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.compound.bgCanvasDefault.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $context.serverConfirmationScreenAlertInfo)
        .alert(item: $context.loginWithEmailAlertInfo)
    }
    
    var header: some View {
        VStack(spacing: 8) {
            BigIcon(icon: \.lockSolid)
                .padding(.bottom, 8)
            
            Text(L10n.screenLoginTitle)
                .font(.compound.headingMDBold)
                .multilineTextAlignment(.center)
                .foregroundColor(.compound.textPrimary)
        }
        .padding(.horizontal, 16)
    }
    
    var loginForm: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.screenLoginFormHeader)
                .font(.compound.bodySM)
                .foregroundColor(.compound.textPrimary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            TextField(text: $context.username) {
                Text(L10n.commonEmail).foregroundColor(.compound.textSecondary)
            }
            .focused($isUsernameFocused)
            .textFieldStyle(.element(accessibilityIdentifier: A11yIdentifiers.loginScreen.emailUsername))
            .disableAutocorrection(true)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .submitLabel(.done)
            .onSubmit(submit)
            .padding(.bottom, 20)
            
            Spacer().frame(height: 32)

            Button(action: submit) {
                Text(L10n.actionContinue)
            }
            .buttonStyle(.compound(.primary))
            .disabled(!context.viewState.canSubmit)
            .accessibilityIdentifier(A11yIdentifiers.loginScreen.continue)
        }
    }
    
    private func submit() {
        guard context.viewState.canSubmit else { return }
        context.send(viewAction: .next)
        isUsernameFocused = false
    }
}

// MARK: - Previews

struct LoginWithEmailScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()
    static let viewModelWithLogin = makeViewModel(login: "user@example.com")
    static let viewModelLoading = makeViewModel(login: "user@example.com", isLoading: true)
    
    static var previews: some View {
        NavigationStack {
            LoginWithEmailScreen(context: viewModel.context)
        }
        .previewDisplayName("Initial")
        
        NavigationStack {
            LoginWithEmailScreen(context: viewModelLoading.context)
        }
        .previewDisplayName("With Login")
        
        NavigationStack {
            LoginWithEmailScreen(context: viewModelLoading.context)
        }
        .previewDisplayName("Loading")
    }
    
    static func makeViewModel(login: String = "", isLoading: Bool = false) -> LoginWithEmailScreenViewModel {
        let viewModel = LoginWithEmailScreenViewModel(authenticationService: AuthenticationService.mock,
                                                      appSettings: ServiceLocator.shared.settings,
                                                      userIndicatorController: UserIndicatorControllerMock())
        
        viewModel.state.bindings.username = login
        
        viewModel.state.isLoading = isLoading
        
        return viewModel
    }
}
