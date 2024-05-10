import UIKit

final class AlertBuilder {
    static func buildAlertController(for model: AlertModel) -> UIAlertController {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: model.prefferedStyle
        )

        if let actions = model.actionModels {
            actions.forEach {
                alertController.addAction(
                    UIAlertAction(
                        title: $0.title,
                        style: $0.style,
                        handler: $0.handler
                    )
                )
            }
        } else {
            let closeAction = CommonAlertActionModels.closeAction

            alertController.addAction(
                UIAlertAction(
                    title: closeAction.title,
                    style: closeAction.style
                )
            )
        }
        return alertController
    }
}
