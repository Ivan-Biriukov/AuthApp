// MARK: - Imports

import UIKit
import Combine

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
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = AuthViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var titleLabel = UILabel()
    private lazy var contentBubbleView = UIView()
    private lazy var loginEmailField = AppTextField(style: .email, placeholderText: "Enter your email")
    private lazy var loginPasswordField = AppTextField(style: .password, placeholderText: "Enter password")
    private lazy var actionButton = AppMainButton(initialText: "Вход")
    
    
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
        actionButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
    }
    
    func addSubviews() {
        [titleLabel,
         contentBubbleView].forEach {
            view.addSubview($0)
        }
        
        [loginEmailField,
         loginPasswordField,
         actionButton].forEach {
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
            
            loginEmailField.topAnchor.constraint(equalTo: contentBubbleView.topAnchor, constant: 25),
            loginEmailField.centerXAnchor.constraint(equalTo: contentBubbleView.centerXAnchor),
            loginEmailField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            loginEmailField.widthAnchor.constraint(equalToConstant: Constants.fieldsWidth),
            
            loginPasswordField.topAnchor.constraint(equalTo: loginEmailField.bottomAnchor, constant: 25),
            loginPasswordField.centerXAnchor.constraint(equalTo: contentBubbleView.centerXAnchor),
            loginPasswordField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            loginPasswordField.widthAnchor.constraint(equalToConstant: Constants.fieldsWidth),
            
            actionButton.bottomAnchor.constraint(equalTo: contentBubbleView.bottomAnchor, constant: Constants.actionButtonBottomOffsets),
            actionButton.centerXAnchor.constraint(equalTo: contentBubbleView.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: Constants.actionButtonWidth),
            actionButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonHeight)
        ])
    }
}

// MARK: - Actions

private extension AuthViewController {
    @objc func actionButtonPressed() {
        viewModel.submitLogin()
        print(234234)
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
        
        viewModel.isLoginEnabled
            .assign(to: \.isEnabled, on: actionButton)
            .store(in: &cancellables)
        
        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.actionButton.isEnabled = false
                    self?.actionButton.updateText(with: "Loading...")
                case .success:
                    self?.actionButton.isEnabled = true
                    self?.actionButton.updateText(with: "Вход")
                case .failed:
                    self?.actionButton.isEnabled = true
                    self?.actionButton.updateText(with: "Вход")
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
