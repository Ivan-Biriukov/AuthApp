import Foundation
import Firebase
import FirebaseAuth

protocol AuthServiceProtocol {
    func createUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> ())
    func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> ())
    func googleLogin(with credential: AuthCredential, completion: @escaping (Result<User, Error>) -> ())
    func logout(completion: @escaping (Result<Bool, Error>) -> ())
}

final class AuthService: AuthServiceProtocol {
    
    func createUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            result?.user.sendEmailVerification(completion: { error in
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let user = result?.user else {
                    completion(.failure(AuthError.unknownError))
                    return
                }
                completion(.success(user))
            })
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            if let current = result?.user, current.isEmailVerified {
                completion(.success(current))
            } else {
                completion(.failure(AuthError.emailNotVerified))
            }
        }
    }
    
    func googleLogin(with credentional: AuthCredential, completion: @escaping (Result<User, any Error>) -> ()) {
        Auth.auth().signIn(with: credentional) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            } else {
                completion(.failure(AuthError.unknownError))
            }
        }
    }
    
    func logout(completion: @escaping (Result<Bool, Error>) -> ()) {
        do {
            try Auth.auth().signOut()
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
}
