import Foundation
import FirebaseAuth
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
    @Published var presentMainScreen: Bool = false
    
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
                            actionModels: [AlertActionModel(
                                title: "Ok",
                                style: .default, handler: { [weak self] alertAction in
                                    self?.presentMainScreen = true
                                })
                            ]
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
                        self.presentMainScreen = false
                }
            }
        }
    }
    
    func submitRegister() {
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
    
    func submitGoogleLogin(with credential:AuthCredential) {
        state = .loading
        
        authService.googleLogin(with: credential) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.state = .success
                self?.errorState = .succeed
                self?.alertModel = .init(
                    title: "Успех",
                    message: "Вход через google успешно выполнен",
                    prefferedStyle: .alert,
                    actionModels: [AlertActionModel(
                        title: "Ok",
                        style: .default, handler: { [weak self] alertAction in
                            self?.presentMainScreen = true
                        })
                    ]
                )
            case .failure(let error):
                self?.state = .failed
                self?.errorState = .failure
                self?.alertModel = .init(
                    title: "Ошибка авторизации",
                    message: "В ходе авторизации возникли следующие ошибки: \(error.localizedDescription)",
                    prefferedStyle: .alert,
                    actionModels: [CommonAlertActionModels.closeAction]
                )
            }
        }
    }
    
    func submitPasswordRecovery(for email: String) {
        state = .loading
        
        authService.resotrePassword(for: email) { [weak self] error in
            if let e = error {
                self?.state = .failed
                self?.errorState = .failure
                self?.alertModel = .init(
                    title: "Ошибка восстановления",
                    message: "При попытке восстановления пароля возникли следующие ошибки: \(e.localizedDescription) \n Пожалуйста повторите попытку.",
                    prefferedStyle: .alert,
                    actionModels: [CommonAlertActionModels.closeAction]
                )
            } else {
                self?.state = .success
                self?.errorState = .succeed
                self?.alertModel = .init(
                    title: "Успешно",
                    message: "На указанный адрес электронной почты было отправлено письмо с инструкциями по восстановлению пароля!",
                    prefferedStyle: .alert,
                    actionModels: [CommonAlertActionModels.closeAction]
                )
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
