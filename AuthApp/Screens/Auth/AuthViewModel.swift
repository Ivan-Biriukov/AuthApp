import Foundation
import Combine

enum ViewStates {
    case loading
    case success
    case failed
    case none
}

enum AuthScetionState {
    case signIn
    case signUp
}

final class AuthViewModel {
    @Published var email = ""
    @Published var password = ""
    @Published var state: ViewStates = .none
    @Published var authState: AuthScetionState = .signIn
    
    var isValidEmailPublisher: AnyPublisher<Bool, Never> {
        $email
            .map { $0.isEmail() }
            .eraseToAnyPublisher()
    }
    
    var isValidPasswordPublisher: AnyPublisher<Bool, Never> {
        $password
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    var isLoginEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isValidEmailPublisher, isValidPasswordPublisher)
            .map {$0 && $1}
            .eraseToAnyPublisher()
    }
    
    func submitLogin() {
        state = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else {
                return
            }
            
            if isCorrectLogin() {
                self.state = .success
            } else {
                self.state = .failed
            }
        }
    }
    
    func switchToAutherisation() {
        if authState != .signIn {
            authState = .signIn
        }
    }
    
    func switchToRegistration() {
        if authState != .signUp {
            authState = .signUp
        }
    }
    
    func isCorrectLogin() -> Bool {
        return email == "test@mail.ru" && password == "12345"
    }
    
}
