//
//  QuizModels.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import Foundation

struct Quiz: Codable {
    let id: String
    var title: String
    var description: String?
    var timeLimit: Int
    var attemptsAllowed: Int
    var questions: [Question]?
    var isPublic: Bool
    var status: String         // "pending" | "approved"
    var shuffleQuestions: Bool
    var shuffleAnswers: Bool
    var createdAt: String?
    var author: QuizAuthor?

    private enum CodingKeys: String, CodingKey {
        case id
        case title, description, timeLimit, attemptsAllowed
        case questions, isPublic, status
        case shuffleQuestions, shuffleAnswers, createdAt, author
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
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Đề thi"
        description = try container.decodeIfPresent(String.self, forKey: .description)
        timeLimit = try container.decodeIfPresent(Int.self, forKey: .timeLimit) ?? 0
        attemptsAllowed = try container.decodeIfPresent(Int.self, forKey: .attemptsAllowed) ?? 0
        questions = try container.decodeIfPresent([Question].self, forKey: .questions)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "pending"
        shuffleQuestions = try container.decodeIfPresent(Bool.self, forKey: .shuffleQuestions) ?? false
        shuffleAnswers = try container.decodeIfPresent(Bool.self, forKey: .shuffleAnswers) ?? false
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        author = try container.decodeIfPresent(QuizAuthor.self, forKey: .author)
    }
    
    var isApproved: Bool { status == "approved" }
    var questionCount: Int { questions?.count ?? 0 }
}

struct QuizAuthor: Codable {
    let id: String?
    let username: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case username
    }

    private enum _IDKeys: String, CodingKey {
        case _id
    }

    init(id: String?, username: String?) {
        self.id = id
        self.username = username
    }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(),
           let id = try? single.decode(String.self) {
            self.id = id
            self.username = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try decoder.container(keyedBy: _IDKeys.self)

        if let decodedId = try? container.decodeIfPresent(String.self, forKey: .id) {
            id = decodedId
        } else {
            id = try idContainer.decodeIfPresent(String.self, forKey: ._id)
        }
        username = try container.decodeIfPresent(String.self, forKey: .username)
    }
}

struct PublicQuizzesResponse: Codable {
    let quizzes: [Quiz]
    let currentPage: Int
    let totalPages: Int
    let totalQuizzes: Int
}

struct QuizReview: Codable {
    let id: String
    let rating: Int
    let comment: String
    let createdAt: String?
    let user: QuizReviewUser?

    private enum CodingKeys: String, CodingKey {
        case id
        case rating, comment, createdAt, user
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
        rating = try container.decodeIfPresent(Int.self, forKey: .rating) ?? 0
        comment = try container.decodeIfPresent(String.self, forKey: .comment) ?? ""
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        user = try container.decodeIfPresent(QuizReviewUser.self, forKey: .user)
    }
}

struct QuizReviewUser: Codable {
    let id: String?
    let username: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case username
    }

    private enum _IDKeys: String, CodingKey {
        case _id
    }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(),
           let id = try? single.decode(String.self) {
            self.id = id
            self.username = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try decoder.container(keyedBy: _IDKeys.self)

        if let decodedId = try? container.decodeIfPresent(String.self, forKey: .id) {
            id = decodedId
        } else {
            id = try idContainer.decodeIfPresent(String.self, forKey: ._id)
        }
        username = try container.decodeIfPresent(String.self, forKey: .username)
    }
}

//struct QuizResult: Codable {
//    let id: String
//    var score: Double
//    var correctCount: Int
//    var totalQuestions: Int
//    var createdAt: String?
//    var quiz: QuizSummary?
//    var userAnswers: [UserAnswer]?
//
//    struct QuizSummary: Codable {
//        let id: String
//        let title: String
//        private enum CodingKeys: String, CodingKey {
//            case id = "_id"; case title
//        }
//    }
//
//    struct UserAnswer: Codable {
//        let questionId: String
//        let selectedOption: Int?
//        let isCorrect: Bool
//    }
//
//    private enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case score, correctCount, totalQuestions, createdAt, quiz, userAnswers
//    }
//}

struct SubmitAnswer {
    let questionId: String
    let selectedOption: Int
    let selectedText: String

    func toDictionary() -> [String: Any] {
        ["questionId": questionId, "selectedOption": selectedOption, "selectedText": selectedText]
    }
}
