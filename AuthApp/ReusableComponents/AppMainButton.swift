import UIKit

private struct Constants {
    let cornerRadius: CGFloat = 15
}

final class AppMainButton: UIButton {
    
    // MARK: - Properties
    
    private var initialText: String
    private var isFilledWithColor: Bool
    private var isSmallTextNeeded: Bool
    private let constants = Constants()
    
    override var isEnabled: Bool {
        didSet {
            updateButtonAppearanceForState()
        }
    }
    
    // MARK: - .init()
    
    init(initialText: String, isFilledWithColor: Bool, isSmallTextNeeded: Bool = false) {
        self.initialText = initialText
        self.isFilledWithColor = isFilledWithColor
        self.isSmallTextNeeded = isSmallTextNeeded
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func updateText(with text: String) {
        setTitle(text, for: .normal)
    }
}

// MARK: - Configure

private extension AppMainButton {
    func configure() {
        setTitle(initialText, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false

        switch isFilledWithColor {
        case true:
            layer.cornerRadius = constants.cornerRadius
        case false:
            setTitleColor(AppColors.mainBG, for: .normal)
        }
        
        switch isSmallTextNeeded {
        case true:
            titleLabel?.font = AppFonts.actionButtonSmallFont
        case false:
            titleLabel?.font = AppFonts.actionButtonFont
        }
    }
    
    func updateButtonAppearanceForState() {
        if isFilledWithColor {
            switch isEnabled {
            case true:
                backgroundColor = AppColors.mainBG
                setTitleColor(AppColors.defaultTextColor, for: .normal)
            case false:
                backgroundColor = AppColors.inactiveBg
                setTitleColor(AppColors.inactiveText, for: .normal)
            }
        } else {
            switch isEnabled {
            case true:
                backgroundColor = .clear
                setTitleColor(AppColors.mainBG, for: .normal)
            case false:
                backgroundColor = .clear
                setTitleColor(AppColors.inactiveText, for: .normal)
            }
        }
    }
}
