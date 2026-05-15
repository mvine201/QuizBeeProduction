import Foundation

struct QuestionBank: Codable, Identifiable, Hashable {
    let id: String
    var title: String
    var description: String?
    var createdAt: String?
    var updatedAt: String?
    var questions: [Question]?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case createdAt
        case updatedAt
        case questions
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
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        questions = try container.decodeIfPresent([Question].self, forKey: .questions)
    }
}

struct Question: Codable, Hashable {
    var id: String?
    var questionText: String
    var options: [String]
    var correctAnswer: Int?
    var points: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case questionText
        case options
        case correctAnswer
        case points
    }

    private enum _IDKeys: String, CodingKey {
        case _id
    }

    init(
        id: String? = nil,
        questionText: String,
        options: [String],
        correctAnswer: Int? = nil,
        points: Int = 10
    ) {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.correctAnswer = correctAnswer
        self.points = points
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try decoder.container(keyedBy: _IDKeys.self)

        if let decodedId = try? container.decodeIfPresent(String.self, forKey: .id) {
            id = decodedId
        } else {
            id = try idContainer.decodeIfPresent(String.self, forKey: ._id)
        }
        questionText = try container.decodeIfPresent(String.self, forKey: .questionText) ?? "Câu hỏi"
        options = try container.decodeIfPresent([String].self, forKey: .options) ?? []
        correctAnswer = try container.decodeIfPresent(Int.self, forKey: .correctAnswer)

        if let intPoints = try? container.decode(Int.self, forKey: .points) {
            points = intPoints
        } else if let doublePoints = try? container.decode(Double.self, forKey: .points) {
            points = Int(doublePoints)
        } else {
            points = 10
        }
    }

    func toDictionary() -> [String: Any] {
        var payload: [String: Any] = [
            "questionText": questionText,
            "options": options,
            "correctAnswer": correctAnswer ?? 0,
            "points": points,
        ]

        if let id, !id.isEmpty {
            payload["id"] = id
        }

        return payload
    }
}
