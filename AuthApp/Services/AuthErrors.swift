import Foundation

enum AuthError: String, Error {
    case unknownError = "Неопознанная ошибка, пожалуйста свяжитесь с Администрацией."
    case emailNotVerified = "Почта не подтверждена"
}
