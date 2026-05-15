//
//  ExamDetailViewController.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import UIKit

final class ExamDetailViewController: UIViewController {

    private let quiz: Quiz

    init(quiz: Quiz) {
        self.quiz = quiz
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Thông tin đề thi"
        BeeTheme.applyAppBackground(view)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "flag.fill"),
            style: .plain,
            target: self,
            action: #selector(reportQuiz)
        )
        navigationItem.rightBarButtonItem?.tintColor = BeeTheme.danger
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Báo cáo vi phạm"
        setupUI()
    }

    private func setupUI() {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyCard(card)
        view.addSubview(card)

        let titleLabel = makeInfoLabel(quiz.title, font: .systemFont(ofSize: 22, weight: .black))
        titleLabel.textColor = BeeTheme.ink
        let rows = UIStackView(arrangedSubviews: [
            makeRow(icon: "questionmark.circle.fill", text: "\(quiz.questionCount) câu hỏi"),
            makeRow(icon: "clock.fill",               text: "\(quiz.timeLimit) phút"),
            makeRow(icon: "arrow.clockwise",          text: quiz.attemptsAllowed == 0 ? "Không giới hạn lượt" : "\(quiz.attemptsAllowed) lượt làm"),
            makeRow(icon: "checkmark.seal.fill",      text: quiz.isApproved ? "Đã được duyệt" : "Đang chờ duyệt"),
        ])
        rows.axis = .vertical
        rows.spacing = 14

        let startButton = UIButton(type: .system)
        BeeTheme.primaryButton(startButton, title: "Bắt đầu làm bài", icon: "play.fill")
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        startButton.addTarget(self, action: #selector(startExam), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, rows, startButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28),
        ])
    }

    @objc private func startExam() {
        let loadingAlert = UIAlertController(title: nil, message: "Đang tải đề thi...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        QuizAPIService.shared.getQuizForTake(id: quiz.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let quiz):
                        let takeVC = TakeExamViewController(quiz: quiz)
                        takeVC.modalPresentationStyle = .fullScreen
                        self.present(takeVC, animated: true)
                    case .failure:
                        let a = UIAlertController(title: "Lỗi", message: "Không thể tải đề thi", preferredStyle: .alert)
                        a.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(a, animated: true)
                    }
                }
            }
        }
    }

    @objc private func reportQuiz() {
        present(QuizReportViewController(quizId: quiz.id), animated: true)
    }

    private func makeInfoLabel(_ text: String, font: UIFont) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.numberOfLines = 0
        return l
    }

    private func makeRow(icon: String, text: String) -> UIView {
        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = BeeTheme.amber
        img.widthAnchor.constraint(equalToConstant: 22).isActive = true
        img.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = BeeTheme.ink

        let row = UIStackView(arrangedSubviews: [img, lbl])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        return row
    }
}
