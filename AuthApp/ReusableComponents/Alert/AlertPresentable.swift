import UIKit

protocol AlertPresentable: UIViewController {
    func presentAlert(_ alert: UIAlertController)
    
}

extension AlertPresentable {
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true)
    }
}
