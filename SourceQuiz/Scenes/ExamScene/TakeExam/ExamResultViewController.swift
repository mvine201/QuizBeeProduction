//
//  ExamResultViewController.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import UIKit

final class ExamResultViewController: UIViewController {

    private let quiz: Quiz
    private let result: QuizResult
    private let questions: [Question]
    private let userAnswers: [Int: (option: Int, text: String)]
    private let ratingControl = UISegmentedControl(items: ["1", "2", "3", "4", "5"])
    private let reviewTextView = UITextView()
    private let reviewStatusLabel = UILabel()
    private lazy var submitReviewButton: UIButton = {
        let button = UIButton(type: .system)
        BeeTheme.primaryButton(button, title: "Gửi đánh giá", icon: "paperplane.fill")
        button.heightAnchor.constraint(equalToConstant: 46).isActive = true
        button.addTarget(self, action: #selector(submitReview), for: .touchUpInside)
        return button
    }()

    init(quiz: Quiz, result: QuizResult, questions: [Question], userAnswers: [Int: (option: Int, text: String)]) {
        self.quiz = quiz; self.result = result
        self.questions = questions; self.userAnswers = userAnswers
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = BeeTheme.cream
        tv.keyboardDismissMode = .interactive
        tv.register(ResultQuestionCell.self, forCellReuseIdentifier: ResultQuestionCell.reuseID)
        tv.dataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 250
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kết quả"
        BeeTheme.applyAppBackground(view)
        navigationItem.hidesBackButton = true
        setupUI()
        enableKeyboardDismissOnTap()
        
    }
    private func setupUI() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func goToHistory() {
        let nav = presentingViewController?.presentingViewController as? UINavigationController
                   ?? (presentingViewController?.presentingViewController as? UITabBarController)?.selectedViewController as? UINavigationController

            // Dismiss toàn bộ modal stack, push History
            nav?.dismiss(animated: false)
            nav?.pushViewController(ExamHistoryViewController(), animated: true)
    }
}

// MARK: - DataSource
extension ExamResultViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 2 ? questions.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Summary card
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            let card = buildSummaryCard()
            card.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(card)
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
                card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            ])
            return cell
        } else if indexPath.section == 1 {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            let card = buildReviewCard()
            card.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(card)
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            ])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultQuestionCell.reuseID, for: indexPath) as! ResultQuestionCell
            let q = questions[indexPath.row]
            let questionID = q.id ?? ""
            let serverAnswer = result.userAnswers?.first(where: { $0.questionId == questionID })
            let isCorrect = serverAnswer?.isCorrect ?? false
            let userAns = serverAnswer?.selectedOption

            cell.configure(question: q, index: indexPath.row + 1, userAnswer: userAns, isCorrect: isCorrect)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 2 ? "Chi tiết từng câu" : nil
    }

    private func buildSummaryCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        // Score circle
        let scoreCircle = UIView()
        scoreCircle.backgroundColor = BeeTheme.softHoney
        scoreCircle.layer.cornerRadius = 50
        scoreCircle.translatesAutoresizingMaskIntoConstraints = false
        scoreCircle.widthAnchor.constraint(equalToConstant: 100).isActive = true
        scoreCircle.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let scoreLabel = UILabel()
        scoreLabel.text = String(format: "%.1f", result.score)
        scoreLabel.font = .systemFont(ofSize: 36, weight: .bold)
        scoreLabel.textColor = result.score >= 5 ? BeeTheme.success : BeeTheme.danger
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCircle.addSubview(scoreLabel)
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: scoreCircle.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreCircle.centerYAnchor),
        ])

        let congratsLabel = UILabel()
        congratsLabel.text = result.score >= 8 ? "Xuất sắc!" : result.score >= 5 ? "Khá tốt!" : "Cần luyện thêm"
        congratsLabel.font = .systemFont(ofSize: 20, weight: .bold)
        congratsLabel.textColor = BeeTheme.ink
        congratsLabel.textAlignment = .center

        let correctLabel = UILabel()
        correctLabel.text = "Đúng \(result.correctCount)/\(result.totalQuestions) câu"
        correctLabel.font = .systemFont(ofSize: 15)
        correctLabel.textColor = BeeTheme.muted
        correctLabel.textAlignment = .center

        let historyBtn = UIButton(type: .system)
        historyBtn.setTitle("Xem lịch sử làm bài →", for: .normal)
        historyBtn.tintColor = BeeTheme.amber
        historyBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        historyBtn.addTarget(self, action: #selector(goToHistory), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [scoreCircle, congratsLabel, correctLabel, historyBtn])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
        ])
        return card
    }

    private func buildReviewCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        let titleLabel = UILabel()
        titleLabel.text = "Đánh giá đề thi"
        titleLabel.font = .systemFont(ofSize: 20, weight: .black)
        titleLabel.textColor = BeeTheme.ink

        let hintLabel = UILabel()
        hintLabel.text = "Chia sẻ nhận xét của bạn sau khi hoàn thành bài thi."
        hintLabel.font = .systemFont(ofSize: 14)
        hintLabel.textColor = BeeTheme.muted
        hintLabel.numberOfLines = 0

        ratingControl.selectedSegmentIndex = 4
        BeeTheme.styleSegment(ratingControl)

        BeeTheme.styleTextView(reviewTextView)
        reviewTextView.heightAnchor.constraint(equalToConstant: 92).isActive = true
        configureKeyboardDismissal(for: [reviewTextView])

        reviewStatusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        reviewStatusLabel.textColor = BeeTheme.muted
        reviewStatusLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            hintLabel,
            ratingControl,
            reviewTextView,
            submitReviewButton,
            reviewStatusLabel,
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])

        return card
    }

    @objc private func submitReview() {
        let comment = reviewTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !comment.isEmpty else {
            reviewStatusLabel.text = "Vui lòng nhập nội dung đánh giá."
            reviewStatusLabel.textColor = BeeTheme.danger
            return
        }

        submitReviewButton.isEnabled = false
        reviewStatusLabel.text = "Đang gửi đánh giá..."
        reviewStatusLabel.textColor = BeeTheme.muted

        QuizAPIService.shared.addReview(
            quizId: quiz.id,
            rating: ratingControl.selectedSegmentIndex + 1,
            comment: comment
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success:
                    self.reviewTextView.isEditable = false
                    self.ratingControl.isEnabled = false
                    self.submitReviewButton.isHidden = true
                    self.reviewStatusLabel.text = "Cảm ơn bạn đã gửi đánh giá."
                    self.reviewStatusLabel.textColor = BeeTheme.success
                case .failure(let error):
                    self.submitReviewButton.isEnabled = true
                    self.reviewStatusLabel.text = error.localizedDescription
                    self.reviewStatusLabel.textColor = BeeTheme.danger
                }
            }
        }
    }
}

// MARK: - Result Question Cell
final class ResultQuestionCell: UITableViewCell {
    static let reuseID = "ResultQuestionCell"

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1.5
        return v
    }()

    private let indexLabel   = UILabel()
    private let questionLabel = UILabel()
    private let optionsStack  = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        indexLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        questionLabel.font = .systemFont(ofSize: 14)
        questionLabel.textColor = BeeTheme.ink
        questionLabel.numberOfLines = 0
        optionsStack.axis = .vertical
        optionsStack.spacing = 6

        [indexLabel, questionLabel, optionsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            indexLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            indexLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            indexLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            questionLabel.topAnchor.constraint(equalTo: indexLabel.bottomAnchor, constant: 4),
            questionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            questionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            optionsStack.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            optionsStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            optionsStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            optionsStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(question: Question, index: Int, userAnswer: Int?, isCorrect: Bool) {
        cardView.backgroundColor = isCorrect
            ? BeeTheme.success.withAlphaComponent(0.08)
            : BeeTheme.danger.withAlphaComponent(0.08)
        cardView.layer.borderColor = (isCorrect ? BeeTheme.success : BeeTheme.danger).cgColor

        indexLabel.text  = isCorrect ? "Đúng - Câu \(index)" : "Sai - Câu \(index)"
        indexLabel.textColor = isCorrect ? BeeTheme.success : BeeTheme.danger
        questionLabel.text = question.questionText

        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, opt) in question.options.enumerated() {
            let lbl = UILabel()
            let prefix = ["A", "B", "C", "D"][safe: i] ?? "\(i)"
            lbl.text = "\(prefix). \(opt)"
            lbl.font = .systemFont(ofSize: 13)
            lbl.numberOfLines = 0

            if let correctAnswer = question.correctAnswer, i == correctAnswer {
                lbl.textColor = BeeTheme.success
                lbl.font = .systemFont(ofSize: 13, weight: .semibold)
            } else if i == userAnswer && !isCorrect {
                lbl.textColor = BeeTheme.danger
                lbl.font = .systemFont(ofSize: 13, weight: .semibold)
            } else if i == userAnswer && isCorrect {
                lbl.textColor = BeeTheme.success
                lbl.font = .systemFont(ofSize: 13, weight: .semibold)
            } else {
                lbl.textColor = BeeTheme.muted
            }
            optionsStack.addArrangedSubview(lbl)
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    static let openExamHistory = Notification.Name("openExamHistory")
}
