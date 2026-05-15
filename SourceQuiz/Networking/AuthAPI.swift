//
//  AuthAPI.swift
//  Quiz Bee
//
//  Created by Assistant on 11/4/26.
//

import Foundation

// MARK: - Errors
public enum APIError: Error, LocalizedError {
    case invalidURL
    case decodingFailed
    case server(String)
    case unauthorized
    case forbidden

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL không hợp lệ"
        case .decodingFailed: return "Không đọc được dữ liệu"
        case .server(let msg): return msg
        case .unauthorized: return "Không được phép"
        case .forbidden: return "Bị từ chối truy cập"
        }
    }
}

// MARK: - Models
public struct AuthUser: Codable {
    public let id: String
    public let username: String
    public let email: String?
    public let role: String?

    private enum CodingKeys: String, CodingKey {
        case id, username, email, role
    }

    private enum _IDKeys: String, CodingKey {
        case _id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try decoder.container(keyedBy: _IDKeys.self)

        if let decodedId = try? container.decode(String.self, forKey: .id) {
            self.id = decodedId
        } else {
            self.id = try idContainer.decode(String.self, forKey: ._id)
        }
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? "Người dùng"
        email = try container.decodeIfPresent(String.self, forKey: .email)
        role = try container.decodeIfPresent(String.self, forKey: .role)
    }
}

public struct LoginResponse: Codable {
    public let token: String
    public let user: AuthUser
}

public struct RegisterResponse: Codable {
    public let message: String
    public let user: AuthUser?
}

public struct MessageResponse: Codable {
    public let message: String
}

// MARK: - API
public final class AuthAPI {
    public static let shared = AuthAPI()
    private init() {}

    // Đăng ký
    public func register(username: String, email: String, password: String) async throws -> RegisterResponse {
        try await APIClient.shared.register(username: username, email: email, password: password)
    }

    // Đăng nhập
    public func login(email: String, password: String) async throws -> LoginResponse {
        try await APIClient.shared.login(email: email, password: password)
    }

    // Quên mật khẩu - gửi mã OTP
    public func forgotPassword(email: String) async throws -> MessageResponse {
        try await APIClient.shared.forgotPassword(email: email)
    }

    // Xác minh OTP
    public func verifyOTP(token: String) async throws -> MessageResponse {
        try await APIClient.shared.verifyOTP(token: token)
    }

    // Đặt lại mật khẩu
    public func resetPassword(token: String, newPassword: String) async throws -> MessageResponse {
        try await APIClient.shared.resetPassword(token: token, newPassword: newPassword)
    }
}
