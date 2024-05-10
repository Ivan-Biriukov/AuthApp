import UIKit

enum FieldStyle {
    case email
    case password
}

final class AppTextField: UITextField {
    
    // MARK: - Properties

    private var style: FieldStyle
    private var placeholderText: String?
    private var isTextHidden: Bool = false
    
    private lazy var showPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = AppColors.mainBG
        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn.addTarget(self, action: #selector(showPasswordTaped), for: .touchUpInside)
        return btn
    }()
    
    private let leftSpace = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 0))
    private let rightSpace = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 0))
    
    private lazy var fieldRightStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0)),
            showPasswordButton,rightSpace
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = -10
        return stack
    }()
    
    // MARK: - .init()
    
    init(style: FieldStyle, placeholderText: String? = nil) {
        self.style = style
        self.placeholderText = placeholderText
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Targets

private extension AppTextField {
    @objc func showPasswordTaped() {
        isTextHidden = !isTextHidden
        self.isSecureTextEntry = isTextHidden
        
        (isTextHidden == true) ? 
        showPasswordButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        :
        showPasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
    }
}

// MARK: - Configure

private extension AppTextField {
    func configure() {
        backgroundColor = AppColors.textFieldBG
        layer.borderColor = AppColors.mainBG?.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        leftView = leftSpace
        leftViewMode = .always
        
        if let placeholderText {
            placeholder = placeholderText
        }
        
        switch style {
        case .email:
            keyboardType = .emailAddress
            rightView = leftSpace
            rightViewMode = .always
        case .password:
            isTextHidden = true
            isSecureTextEntry = true
            keyboardType = .default
            rightViewMode = .always
            rightView = fieldRightStack
        }
    }
}
