//
//  QuizResult.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

struct QuizResult: Codable {
    let id: String
    var score: Double
    var correctCount: Int
    var totalQuestions: Int
    var createdAt: String?
    var quiz: QuizSummary?
    var userAnswers: [UserAnswer]?

    struct QuizSummary: Codable {
        let id: String
        let title: String
        private enum CodingKeys: String, CodingKey {
            case id, title
        }

        private enum _IDKeys: String, CodingKey {
            case _id
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let idContainer = try decoder.container(keyedBy: _IDKeys.self)

            if let decodedId = try? container.decode(String.self, forKey: .id) {
                id = decodedId
            } else {
                id = try idContainer.decode(String.self, forKey: ._id)
            }
            title = try container.decode(String.self, forKey: .title)
        }
    }

    struct UserAnswer: Codable {
        let questionId: String
        let selectedOption: Int?
        let isCorrect: Bool
        private enum CodingKeys: String, CodingKey {
            case questionId, selectedOption, isCorrect
        }
        func toDictionary() -> [String: Any] {
            // Thử chỉ gửi những gì server có trong response mẫu
            return [
                "questionId": questionId,
                "selectedOption": selectedOption as Any // Nếu server cần index
                 //"selectedOption": selectedText // Nếu server cần nội dung chữ
            ]
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case score, correctCount, totalQuestions, createdAt, userAnswers, quiz
    }

    private enum _IDKeys: String, CodingKey {
        case _id
    }

    init(from decoder: Decoder) throws {
        let c      = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try decoder.container(keyedBy: _IDKeys.self)

        if let decodedId = try? c.decode(String.self, forKey: .id) {
            id = decodedId
        } else {
            id = try idContainer.decode(String.self, forKey: ._id)
        }
        score          = try c.decode(Double.self,   forKey: .score)
        correctCount   = try c.decode(Int.self,      forKey: .correctCount)
        totalQuestions = try c.decode(Int.self,      forKey: .totalQuestions)
        createdAt      = try c.decodeIfPresent(String.self,       forKey: .createdAt)
        userAnswers    = try c.decodeIfPresent([UserAnswer].self,  forKey: .userAnswers)
        // quiz có thể là Object hoặc String ID — bỏ qua nếu là string
        quiz = try? c.decodeIfPresent(QuizSummary.self, forKey: .quiz)
    }
}
