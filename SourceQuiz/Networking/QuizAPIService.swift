//
//  QuizAPIService.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import Foundation

final class QuizAPIService {
    static let shared = QuizAPIService()
    private init() {}

    // MARK: - GET Public Quizzes
    func getPublicQuizzes(
        keyword: String? = nil,
        page: Int = 1,
        limit: Int = 6,
        completion: @escaping (Result<PublicQuizzesResponse, Error>) -> Void
    ) {
        Task {
            do {
                completion(.success(try await APIClient.shared.getPublicQuizzes(keyword: keyword, page: page, limit: limit)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - GET My Quizzes
    func getMyQuizzes(completion: @escaping (Result<[Quiz], Error>) -> Void) {
        Task {
            do {
                completion(.success(try await APIClient.shared.getMyQuizzes()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Get Quiz Detail
    func getQuizById(id: String, completion: @escaping (Result<Quiz, Error>) -> Void) {
        Task {
            do {
                completion(.success(try await APIClient.shared.getQuizById(id: id)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Generate Quiz From Bank
    func generateQuizFromBank(params: [String: Any], completion: @escaping (Result<Quiz, Error>) -> Void) {
        Task {
            do {
                completion(.success(try await APIClient.shared.generateQuizFromBank(params: params)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Update Quiz
    func updateQuiz(id: String, body: [String: Any], completion: @escaping (Result<Quiz, Error>) -> Void) {
        Task {
            do {
                completion(.success(try await APIClient.shared.updateQuiz(id: id, body: body)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Delete Quiz
    func deleteQuiz(id: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await APIClient.shared.deleteQuiz(id: id)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    // MARK: - Get Quiz For Take
    func getQuizForTake(id: String, completion: @escaping (Result<Quiz, Error>) -> Void) {
        Task {
            do {
                completion(.success(try await APIClient.shared.getQuizForTake(id: id)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Submit Quiz
    func submitQuiz(id: String, answers: [SubmitAnswer], completion: @escaping (Result<QuizResult, Error>) -> Void) {
        Task {
            do {
                completion(.success(try await APIClient.shared.submitQuiz(id: id, answers: answers)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Get History
    func getHistory(completion: @escaping (Result<[QuizResult], Error>) -> Void) {
        Task {
            do {
                completion(.success(try await APIClient.shared.getHistory()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Reviews
    func getQuizReviews(quizId: String, completion: @escaping (Result<[QuizReview], Error>) -> Void) {
        Task {
            do {
                completion(.success(try await APIClient.shared.getQuizReviews(quizId: quizId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func addReview(
        quizId: String,
        rating: Int,
        comment: String,
        completion: @escaping (Result<QuizReview, Error>) -> Void
    ) {
        Task {
            do {
                completion(.success(try await APIClient.shared.addReview(quizId: quizId, rating: rating, comment: comment)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Reports
    func reportQuiz(
        quizId: String,
        reason: String,
        description: String,
        completion: @escaping (Result<MessageResponse, Error>) -> Void
    ) {
        Task {
            do {
                completion(.success(try await APIClient.shared.reportQuiz(
                    quizId: quizId,
                    reason: reason,
                    description: description
                )))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
