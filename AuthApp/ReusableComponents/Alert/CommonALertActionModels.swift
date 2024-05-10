import UIKit

enum CommonAlertActionModels {

    static let terminateAppAction = AlertActionModel(
        title: "OK",
        style: .default,
        handler: { _ in
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(-1)
            }
        }
    )

    static let closeAction = AlertActionModel(
        title: "Close",
        style: .cancel
    )

}
