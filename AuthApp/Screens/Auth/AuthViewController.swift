// MARK: - Imports

import UIKit
import Combine
import Firebase
import GoogleSignIn

// MARK: - Constants

fileprivate enum Constants {
    static let mainBackgroundColor: UIColor? = .init(named: "background")
    static let contentViewBackgroundColor: UIColor? = .init(named: "additionalyBackground")
    static let titleLabelTopInsets: CGFloat = 120
    static let contentViewWidth: CGFloat = UIScreen.main.bounds.width
    static let contentViewHeight: CGFloat = UIScreen.main.bounds.height / 1.7
    static let contentViewCornerRadius: CGFloat = 40
    static let fieldHeight: CGFloat = 40
    static let fieldsWidth: CGFloat = UIScreen.main.bounds.width - 100
    static let actionButtonBottomOffsets: CGFloat = -50
    static let actionButtonWidth: CGFloat = UIScreen.main.bounds.width / 1.5
    static let actionButtonHeight: CGFloat = 40
    static let underlineViewSignInPosition: CGRect = CGRect(x: 20, y: 60, width: 80, height: 4)
    static let underlineViewSignUpPosition: CGRect = CGRect(x: Int(UIScreen.main.bounds.width) - 110, y: 60, width: 90, height: 4)
    static let commonInsetValue: CGFloat = 20
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = AuthViewModel(authService: AuthService())
    private var isSignInSelected: Bool = true
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = AppColors.defaultTextColor
        lb.font = AppFonts.getFont(ofSize: 33, weight: .bold)
        return lb
    }()
    private lazy var contentBubbleView = UIView()
    private lazy var switchToSignInButton = AppMainButton(initialText: "Sign In", isFilledWithColor: false)
    private lazy var switchToSignUpButton = AppMainButton(initialText: "Sign up", isFilledWithColor: false)
    
    private lazy var underlineView: UIView = {
        let view = UIView(frame: Constants.underlineViewSignInPosition)
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var loginEmailField = AppTextField(style: .email, placeholderText: "Enter your email")
    private lazy var loginPasswordField = AppTextField(style: .password, placeholderText: "Enter password")
    private lazy var loginActionButton = AppMainButton(initialText: "Вход", isFilledWithColor: true)
    
    private lazy var loginStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [loginEmailField, loginPasswordField])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 25
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var registerEmailField = AppTextField(style: .email, placeholderText: "Enter your email (login)")
    private lazy var registerFirstEnterPasswordField = AppTextField(style: .password, placeholderText: "Create password")
    private lazy var registerConfirmPasswordField = AppTextField(style: .password, placeholderText: "Repeat password")
    
    private lazy var registerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [registerEmailField, registerFirstEnterPasswordField, registerConfirmPasswordField])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 25
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var registrationActionButton = AppMainButton(initialText: "Регистрация", isFilledWithColor: true)
    
    private lazy var googleSignInButton: UIButton = {
        let btn = UIButton()
        btn.setImage(AppImages.googleImage, for: .normal)
        btn.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        btn.layer.cornerRadius = 30
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        initialConfigure()
        addSubviews()
        setupConstraints()
        bindViewModel()
    }
}

// MARK: - Configure

private extension AuthViewController {
    func initialConfigure() {
        view.backgroundColor = Constants.mainBackgroundColor
        contentBubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentBubbleView.backgroundColor = Constants.contentViewBackgroundColor
        contentBubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentBubbleView.layer.cornerRadius = Constants.contentViewCornerRadius
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        loginActionButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        registrationActionButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        switchToSignInButton.addTarget(self, action: #selector(switchToSignInTaped), for: .touchUpInside)
        switchToSignUpButton.addTarget(self, action: #selector(switchToSignUpTaped), for: .touchUpInside)
    }
    
    func addSubviews() {
        [titleLabel,
         googleSignInButton,
         contentBubbleView].forEach {
            view.addSubview($0)
        }
        
        [switchToSignInButton,
         switchToSignUpButton,
         underlineView,
         loginStackView,
         registerStackView,
         loginActionButton,
         registrationActionButton].forEach {
            contentBubbleView.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.titleLabelTopInsets),
            
            contentBubbleView.widthAnchor.constraint(equalToConstant: Constants.contentViewWidth),
            contentBubbleView.heightAnchor.constraint(equalToConstant: Constants.contentViewHeight),
            contentBubbleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentBubbleView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            googleSignInButton.widthAnchor.constraint(equalToConstant: 60),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 60),
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.bottomAnchor.constraint(equalTo: contentBubbleView.topAnchor, constant: -10),
            
            switchToSignInButton.leadingAnchor.constraint(equalTo: contentBubbleView.leadingAnchor, constant: Constants.commonInsetValue),
            switchToSignInButton.topAnchor.constraint(equalTo: contentBubbleView.topAnchor, constant: Constants.commonInsetValue),
            
            switchToSignUpButton.trailingAnchor.constraint(equalTo: contentBubbleView.trailingAnchor, constant: -Constants.commonInsetValue),
            switchToSignUpButton.topAnchor.constraint(equalTo: contentBubbleView.topAnchor, constant: Constants.commonInsetValue),
            
            loginStackView.topAnchor.constraint(equalTo: switchToSignInButton.bottomAnchor, constant: Constants.commonInsetValue),
            loginStackView.centerXAnchor.constraint(equalTo: contentBubbleView.centerXAnchor),
            
            registerStackView.topAnchor.constraint(equalTo: switchToSignInButton.bottomAnchor, constant: Constants.commonInsetValue),
            registerStackView.centerXAnchor.constraint(equalTo: contentBubbleView.centerXAnchor),
            
            loginEmailField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            loginEmailField.widthAnchor.constraint(equalToConstant: Constants.fieldsWidth),

            loginPasswordField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            loginPasswordField.widthAnchor.constraint(equalToConstant: Constants.fieldsWidth),
            
            registerEmailField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            registerEmailField.widthAnchor.constraint(equalToConstant: Constants.fieldsWidth),
            
            registerFirstEnterPasswordField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            registerFirstEnterPasswordField.widthAnchor.constraint(equalToConstant: Constants.fieldsWidth),
            
            registerConfirmPasswordField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            registerConfirmPasswordField.widthAnchor.constraint(equalToConstant: Constants.fieldsWidth),
            
            loginActionButton.bottomAnchor.constraint(equalTo: contentBubbleView.bottomAnchor, constant: Constants.actionButtonBottomOffsets),
            loginActionButton.centerXAnchor.constraint(equalTo: contentBubbleView.centerXAnchor),
            loginActionButton.widthAnchor.constraint(equalToConstant: Constants.actionButtonWidth),
            loginActionButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonHeight),
            
            registrationActionButton.bottomAnchor.constraint(equalTo: contentBubbleView.bottomAnchor, constant: Constants.actionButtonBottomOffsets),
            registrationActionButton.centerXAnchor.constraint(equalTo: contentBubbleView.centerXAnchor),
            registrationActionButton.widthAnchor.constraint(equalToConstant: Constants.actionButtonWidth),
            registrationActionButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonHeight),
        ])
    }
}

// MARK: - Actions

private extension AuthViewController {
    @objc func actionButtonPressed() {
        viewModel.submitLogin()
    }
    
    @objc func registerButtonPressed() {
        viewModel.sumbitRegister()
    }
    
    @objc func switchToSignInTaped() {
        if isSignInSelected == false {
            isSignInSelected = true
            viewModel.switchToAutherisation()
            UIView.animate(withDuration: 0.3) {
                self.underlineView.frame = Constants.underlineViewSignInPosition
            }
        }
    }
    
    @objc func switchToSignUpTaped() {
        if isSignInSelected == true {
            isSignInSelected = false
            viewModel.switchToRegistration()
            UIView.animate(withDuration: 0.3) {
                self.underlineView.frame = Constants.underlineViewSignUpPosition
            }
        }
    }
    
    @objc func googleTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {  result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            self.viewModel.sumbitGoogleLogin(with: credential)
        }
    }
}

// MARK: - Bindings

private extension AuthViewController {
    func bindViewModel() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: loginEmailField)
            .map { ($0.object as! UITextField).text ?? ""}
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: loginPasswordField)
            .map { ($0.object as! UITextField).text ?? ""}
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: registerEmailField)
            .map { ($0.object as! UITextField).text ?? ""}
            .assign(to: \.registerEmail, on: viewModel)
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: registerFirstEnterPasswordField)
            .map { ($0.object as! UITextField).text ?? ""}
            .assign(to: \.registerPassword, on: viewModel)
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: registerConfirmPasswordField)
            .map { ($0.object as! UITextField).text ?? ""}
            .assign(to: \.registerConfirmPassword, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.isLoginEnabled
            .assign(to: \.isEnabled, on: loginActionButton)
            .store(in: &cancellables)
        
        viewModel.isRegisterEnabled
            .assign(to: \.isEnabled, on: registrationActionButton)
            .store(in: &cancellables)
        
        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.loginActionButton.isEnabled = false
                    self?.loginActionButton.updateText(with: "Loading...")
                case .success:
                    self?.loginActionButton.isEnabled = true
                    self?.loginActionButton.updateText(with: "Вход")
                case .failed:
                    self?.loginActionButton.isEnabled = true
                    self?.loginActionButton.updateText(with: "Вход")
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.$authState
            .sink { [weak self] state in
                switch state {
                case .signIn:
                    self?.loginStackView.isHidden = false
                    self?.registerStackView.isHidden = true
                    //self?.loginActionButton.updateText(with: "Вход")
                    self?.titleLabel.text = "Авторизация"
                    self?.registrationActionButton.isHidden = true
                    self?.loginActionButton.isHidden = false
                case .signUp:
                    self?.loginStackView.isHidden = true
                    self?.registerStackView.isHidden = false
                    //self?.loginActionButton.updateText(with: "Регистрация")
                    self?.titleLabel.text = "Регистрация"
                    self?.loginActionButton.isHidden = true
                    self?.registrationActionButton.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorState
            .sink { [weak self] state in
                switch state {
                case .succeed:
                    self?.presentAlert(AlertBuilder.buildAlertController(for: (self?.viewModel.alertModel)!))
                case .failure:
                    self?.presentAlert(AlertBuilder.buildAlertController(for: (self?.viewModel.alertModel)!))
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - AlertPresentable

extension AuthViewController: AlertPresentable {}
