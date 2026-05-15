import Alamofire
import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let tokenKey = "authToken"
    private var authToken: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    private var baseURLString: String {
        if let configuredURL = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
           !configuredURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return configuredURL
        }
        return "https://quiz-bee-4vqz.onrender.com/api"
    }

    private var jsonDecoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    // MARK: - Auth APIs

    func register(username: String, email: String, password: String) async throws -> RegisterResponse {
        try await send(
            path: "/auth/register",
            method: "POST",
            body: [
                "username": username,
                "email": email,
                "password": password,
            ],
            requiresAuth: false
        )
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await send(
            path: "/auth/login",
            method: "POST",
            body: [
                "email": email,
                "password": password,
            ],
            requiresAuth: false
        )
        setAuthToken(response.token)
        return response
    }

    func forgotPassword(email: String) async throws -> MessageResponse {
        try await send(
            path: "/auth/forgot-password",
            method: "POST",
            body: ["email": email],
            requiresAuth: false
        )
    }

    func verifyOTP(token: String) async throws -> MessageResponse {
        try await send(path: "/auth/verify-otp/\(token)", method: "GET", requiresAuth: false)
    }

    func resetPassword(token: String, newPassword: String) async throws -> MessageResponse {
        try await send(
            path: "/auth/reset-password/\(token)",
            method: "PUT",
            body: ["password": newPassword],
            requiresAuth: false
        )
    }

    // MARK: - User APIs

    func getProfile() async throws -> AuthUser {
        try await send(path: "/users/profile", method: "GET")
    }

    func updateProfile(username: String, email: String) async throws -> AuthUser {
        try await send(
            path: "/users/profile",
            method: "PUT",
            body: [
                "username": username,
                "email": email,
            ]
        )
    }

    func changePassword(oldPassword: String, newPassword: String) async throws -> MessageResponse {
        try await send(
            path: "/users/change-password",
            method: "PUT",
            body: [
                "oldPassword": oldPassword,
                "newPassword": newPassword,
            ]
        )
    }

    // MARK: - Bank APIs

    func getMyBanks() async throws -> [QuestionBank] {
        try await send(path: "/banks", method: "GET")
    }

    func getBank(id: String) async throws -> QuestionBank {
        try await send(path: "/banks/\(id)", method: "GET")
    }

    func createBank(title: String, description: String?, questions: [Question]) async throws -> QuestionBank {
        let response: BankResponse = try await send(
            path: "/banks",
            method: "POST",
            body: [
                "title": title,
                "description": description ?? "",
                "questions": questions.map { $0.toDictionary() },
            ]
        )
        return response.bank
    }

    func updateBank(
        id: String,
        title: String? = nil,
        description: String? = nil,
        questions: [Question]
    ) async throws -> QuestionBank {
        var body: [String: Any] = [
            "questions": questions.map { $0.toDictionary() },
        ]

        if let title, !title.isEmpty {
            body["title"] = title
        }

        if let description {
            body["description"] = description
        }

        let response: BankResponse = try await send(path: "/banks/\(id)", method: "PUT", body: body)
        return response.bank
    }

    func parseFilePreview(fileData: Data, fileName: String) async throws -> [Question] {
        let url = try makeURL(path: "/quizzes/parse-file")
        let response = await AF.upload(
            multipartFormData: { formData in
                formData.append(
                    fileData,
                    withName: "file",
                    fileName: fileName,
                    mimeType: "application/octet-stream"
                )
            },
            to: url,
            headers: makeHeaders(requiresAuth: true)
        )
        .serializingData()
        .response

        let validatedData = try validate(dataResponse: response)

        return try decode(PreviewResponse.self, from: validatedData).questions
    }

    // MARK: - AI APIs

    func generateAIQuestions(topic: String, numQuestions: Int) async throws -> [Question] {
        let response: PreviewResponse = try await send(
            path: "/ai/generate-topic",
            method: "POST",
            body: [
                "topic": topic,
                "numQuestions": numQuestions,
            ]
        )
        return response.questions
    }

    func generateAIQuestions(fileData: Data, fileName: String, numQuestions: Int) async throws -> [Question] {
        let url = try makeURL(path: "/ai/generate-file")
        let response = await AF.upload(
            multipartFormData: { formData in
                formData.append(
                    fileData,
                    withName: "file",
                    fileName: fileName,
                    mimeType: fileName.lowercased().hasSuffix(".pdf")
                        ? "application/pdf"
                        : "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                )
                if let data = "\(numQuestions)".data(using: .utf8) {
                    formData.append(data, withName: "numQuestions")
                }
            },
            to: url,
            headers: makeHeaders(requiresAuth: true)
        )
        .serializingData()
        .response

        let validatedData = try validate(dataResponse: response)
        return try decode(PreviewResponse.self, from: validatedData).questions
    }

    // MARK: - Quiz APIs

    func getPublicQuizzes(keyword: String? = nil, page: Int = 1, limit: Int = 6) async throws -> PublicQuizzesResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
        if let keyword, !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }

        let response: PublicQuizzesResponse = try await send(
            path: "/quizzes/public",
            method: "GET",
            queryItems: queryItems
        )
        return response
    }

    func getMyQuizzes() async throws -> [Quiz] {
        try await send(path: "/quizzes", method: "GET")
    }

    func createQuiz(
        title: String,
        description: String?,
        timeLimit: Int,
        attemptsAllowed: Int,
        isPublic: Bool,
        shuffleQuestions: Bool,
        shuffleAnswers: Bool,
        questions: [Question]
    ) async throws -> Quiz {
        let response: QuizResponse = try await send(
            path: "/quizzes",
            method: "POST",
            body: [
                "title": title,
                "description": description ?? "",
                "timeLimit": timeLimit,
                "attemptsAllowed": attemptsAllowed,
                "isPublic": isPublic,
                "shuffleQuestions": shuffleQuestions,
                "shuffleAnswers": shuffleAnswers,
                "questions": questions.map { $0.toDictionary() },
            ]
        )
        return response.quiz
    }

    func getQuizById(id: String) async throws -> Quiz {
        try await send(path: "/quizzes/\(id)", method: "GET")
    }

    func generateQuizFromBank(params: [String: Any]) async throws -> Quiz {
        let response: QuizResponse = try await send(
            path: "/quizzes/generate-from-bank",
            method: "POST",
            body: params
        )
        return response.quiz
    }

    func updateQuiz(id: String, body: [String: Any]) async throws -> Quiz {
        try await send(path: "/quizzes/\(id)", method: "PUT", body: body)
    }

    func deleteQuiz(id: String) async throws {
        let url = try makeURL(path: "/quizzes/\(id)")
        let response = await AF.request(
            url,
            method: .delete,
            headers: makeHeaders(requiresAuth: true)
        )
        .serializingData()
        .response
        _ = try validate(dataResponse: response)
    }

    func getQuizForTake(id: String) async throws -> Quiz {
        try await send(path: "/quizzes/\(id)/take", method: "GET")
    }

    func submitQuiz(id: String, answers: [SubmitAnswer]) async throws -> QuizResult {
        let response: SubmitQuizResponse = try await send(
            path: "/quizzes/\(id)/submit",
            method: "POST",
            body: ["answers": answers.map { $0.toDictionary() }]
        )
        return response.result
    }

    func getHistory() async throws -> [QuizResult] {
        try await send(path: "/quizzes/user/history", method: "GET")
    }

    func getQuizReviews(quizId: String) async throws -> [QuizReview] {
        try await send(path: "/quizzes/\(quizId)/reviews", method: "GET", requiresAuth: false)
    }

    func addReview(quizId: String, rating: Int, comment: String) async throws -> QuizReview {
        try await send(
            path: "/quizzes/reviews",
            method: "POST",
            body: [
                "quizId": quizId,
                "rating": rating,
                "comment": comment,
            ]
        )
    }

    func reportQuiz(quizId: String, reason: String, description: String) async throws -> MessageResponse {
        try await send(
            path: "/reports",
            method: "POST",
            body: [
                "quizId": quizId,
                "reason": reason,
                "description": description,
            ]
        )
    }

    // MARK: - Session

    func setAuthToken(_ token: String?) {
        if let token, !token.isEmpty {
            UserDefaults.standard.set(token, forKey: tokenKey)
        } else {
            UserDefaults.standard.removeObject(forKey: tokenKey)
        }
    }

    func clearAuthToken() {
        setAuthToken(nil)
    }

    // MARK: - Helpers

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        let trimmedBase = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"

        guard var components = URLComponents(string: "\(trimmedBase)\(normalizedPath)") else {
            throw APIError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else { throw APIError.invalidURL }

        return url
    }

    private func send<T: Decodable>(
        path: String,
        method: String,
        body: [String: Any]? = nil,
        queryItems: [URLQueryItem] = [],
        requiresAuth: Bool = true
    ) async throws -> T {
        let httpMethod = HTTPMethod(rawValue: method)
        let url = try makeURL(path: path, queryItems: queryItems)
        let response = await AF.request(
            url,
            method: httpMethod,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: makeHeaders(requiresAuth: requiresAuth)
        )
        .serializingData()
        .response

        let validatedData = try validate(dataResponse: response)
        return try decode(T.self, from: validatedData)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    private func makeHeaders(requiresAuth: Bool) -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]

        if requiresAuth, let token = authToken {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }

        return headers
    }

    private func validate(dataResponse: AFDataResponse<Data>) throws -> Data {
        if let error = dataResponse.error, dataResponse.response == nil {
            throw APIError.server(error.localizedDescription)
        }

        guard let http = dataResponse.response else {
            throw APIError.server("Không có phản hồi hợp lệ từ máy chủ")
        }

        let data = dataResponse.data ?? Data()

        guard 200..<300 ~= http.statusCode else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            if http.statusCode == 403 { throw APIError.forbidden }

            if let message = try? jsonDecoder.decode(MessageResponse.self, from: data).message {
                throw APIError.server(message)
            }

            let fallbackMessage = String(data: data, encoding: .utf8) ?? "Lỗi không xác định (\(http.statusCode))"
            throw APIError.server(fallbackMessage)
        }

        return data
    }
}

private struct PreviewResponse: Decodable {
    let questions: [Question]
}

private struct BankResponse: Decodable {
    let bank: QuestionBank
}

private struct QuizResponse: Decodable {
    let quiz: Quiz
}

private struct SubmitQuizResponse: Decodable {
    let result: QuizResult
}
