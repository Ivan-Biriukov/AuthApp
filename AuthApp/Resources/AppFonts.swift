import UIKit.UIFont

final class AppFonts {
    
    static let actionButtonFont: UIFont = .systemFont(ofSize: 24, weight: .black)
    
    static func getFont(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        return .systemFont(ofSize: ofSize, weight: weight)
    }
}
