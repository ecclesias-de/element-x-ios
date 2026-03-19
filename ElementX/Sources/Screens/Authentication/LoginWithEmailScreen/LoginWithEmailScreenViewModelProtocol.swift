import Combine

@MainActor
protocol LoginWithEmailScreenViewModelProtocol {
    var actionsPublisher: AnyPublisher<LoginWithEmailScreenViewModelAction, Never> { get }
    var context: LoginWithEmailScreenViewModelType.Context { get }
}
