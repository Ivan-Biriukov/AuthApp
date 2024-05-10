import Foundation
import Combine

// MARK: - Conditions States

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

enum ErorrState {
    case succeed
    case failure
    case none
}

// MARK: - AuthViewModel

final class AuthViewModel {
    
    // MARK: - Properties
    
    @Published var email = ""
    @Published var password = ""
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var registerConfirmPassword = ""
    @Published var state: ViewStates = .none
    @Published var authState: AuthScetionState = .signIn
    @Published var errorState: ErorrState = .none
    @Published var alertModel: AlertModel = .init(prefferedStyle: .alert)
    
    private let authService: AuthServiceProtocol
    
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
    
    var isValidRegistrationEmailPublisher: AnyPublisher<Bool, Never> {
        $registerEmail
            .map {$0.isEmail()}
            .eraseToAnyPublisher()
    }
    
    var isValidRegistrationPawwsord: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($registerPassword, $registerConfirmPassword)
            .map { password, confirmPassword  in
                return !password.isEmpty && password == confirmPassword
            }
            .eraseToAnyPublisher()
    }
    
    var isRegisterEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isValidRegistrationEmailPublisher, isValidRegistrationPawwsord)
            .map { $0 && $1}
            .eraseToAnyPublisher()
    }
    
    // MARK: - .init()
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Methods
    
    func submitLogin() {
        state = .loading
        
        authService.loginUser(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self.state = .success
                        self.errorState = .succeed
                        self.alertModel = .init(
                            title: "Данные загрузились",
                            message: "Авторизация прошла успешно!",
                            prefferedStyle: .alert,
                            actionModels: [CommonAlertActionModels.closeAction]
                        )
                    case .failure(let error):
                        self.state = .failed
                        self.errorState = .failure
                        self.alertModel = .init(
                            title: "Ошибка авторизации",
                            message: error.localizedDescription,
                            prefferedStyle: .alert,
                            actionModels: [CommonAlertActionModels.closeAction]
                        )
                }
            }
        }
    }
    
    func sumbitRegister() {
        state = .loading
        
        authService.createUser(email: registerEmail, password: registerConfirmPassword) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.state = .success
                    self.errorState = .succeed
                    self.alertModel = .init(
                        title: "Регистрация завершена",
                        message: "На указанный адрес электронной почты было отправлено письмо с подтверждением регистрации. Для авторизации, пожалуйста активируйте учетную запись!",
                        prefferedStyle: .alert,
                        actionModels: [CommonAlertActionModels.closeAction]
                    )
                case .failure(let error):
                    self.state = .failed
                    self.errorState = .failure
                    self.alertModel = .init(
                        title: "Ошибка регистрации",
                        message: "В ходе выполнения регистрации, возникли следующие ошибки: \(error.localizedDescription).",
                        prefferedStyle: .alert,
                        actionModels: [CommonAlertActionModels.closeAction]
                    )
                }
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
}
