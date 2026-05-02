import Foundation

struct LoginRequestDTO: Codable, Sendable {
    let email: String
    let password: String
}

struct RegisterRequestDTO: Codable, Sendable {
    let name: String
    let email: String
    let phone: String
    let password: String
}

struct UserDTO: Codable, Equatable, Sendable {
    let id: String?
    let email: String?
    let name: String?
    let phone: String?
    let role: String?
}

struct AuthResponseDTO: Codable, Sendable {
    let token: String?
    let accessToken: String?
    let user: UserDTO?

    /// Mirrors AuthResponseDto.tokenValue()
    func tokenValue() -> String? {
        let t = token ?? accessToken
        return t.flatMap { $0.isEmpty ? nil : $0 }
    }
}
