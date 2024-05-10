import UIKit

struct AlertModel {
    var title: String?
    var message: String?
    var prefferedStyle: UIAlertController.Style
    var actionModels: [AlertActionModel]?
}

struct AlertActionModel {
    var title: String?
    var style: UIAlertAction.Style
    var handler: ((UIAlertAction) -> ())?
}
