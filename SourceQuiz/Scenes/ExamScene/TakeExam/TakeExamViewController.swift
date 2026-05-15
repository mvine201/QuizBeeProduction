//
//  TakeExamViewController.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import UIKit

final class TakeExamViewController: UIViewController {

    private let quiz: Quiz
    private var questions: [Question] = []
    private var userAnswers: [Int: (option: Int, text: String)] = [:]
    private var secondsLeft: Int = 0
    private var timer: Timer?

    init(quiz: Quiz) {
        self.quiz = quiz
        self.questions = quiz.questions ?? []
        self.secondsLeft = quiz.timeLimit * 60
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private lazy var timerLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedDigitSystemFont(ofSize: 28, weight: .black)
        l.textColor = BeeTheme.ink
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.72
        l.textAlignment = .right
        l.numberOfLines = 1
        return l
    }()

    private lazy var progressLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = BeeTheme.muted
        return l
    }()

    private lazy var progressView: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .bar)
        v.trackTintColor = BeeTheme.border.withAlphaComponent(0.45)
        v.progressTintColor = BeeTheme.amber
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = BeeTheme.cream
        tv.register(TakeExamQuestionCell.self, forCellReuseIdentifier: TakeExamQuestionCell.reuseID)
        tv.dataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 260
        return tv
    }()

    private lazy var submitButton: UIButton = {
        let btn = UIButton(type: .system)
        BeeTheme.destructiveButton(btn, title: "Nộp bài", icon: "checkmark.seal.fill")
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var headerBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyCard(v, radius: 18)
        return v
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        BeeTheme.applyAppBackground(view)
        setupLayout()
        startTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    // MARK: - Layout
    private func setupLayout() {
        let titleLabel = UILabel()
        titleLabel.text = quiz.title
        titleLabel.font = .systemFont(ofSize: 17, weight: .black)
        titleLabel.textColor = BeeTheme.ink
        titleLabel.numberOfLines = 2

        let questionCountBadge = makeBadge(text: "\(questions.count) câu", icon: "list.bullet.clipboard")
        let timeBadge = makeBadge(text: "\(quiz.timeLimit) phút", icon: "clock")
        let infoRow = UIStackView(arrangedSubviews: [questionCountBadge, timeBadge])
        infoRow.axis = .horizontal
        infoRow.spacing = 8
        infoRow.alignment = .leading

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, infoRow])
        titleStack.axis = .vertical
        titleStack.spacing = 8

        let timeCaption = UILabel()
        timeCaption.text = "Còn lại"
        timeCaption.font = .systemFont(ofSize: 12, weight: .bold)
        timeCaption.textColor = BeeTheme.subtleText
        timeCaption.textAlignment = .right

        let timerIcon = UIImageView(image: UIImage(systemName: "timer"))
        timerIcon.tintColor = BeeTheme.amber
        timerIcon.contentMode = .scaleAspectFit
        timerIcon.translatesAutoresizingMaskIntoConstraints = false
        timerIcon.widthAnchor.constraint(equalToConstant: 22).isActive = true
        timerIcon.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let timerTextStack = UIStackView(arrangedSubviews: [timeCaption, timerLabel])
        timerTextStack.axis = .vertical
        timerTextStack.spacing = 2
        timerTextStack.alignment = .trailing

        let timerPanel = UIStackView(arrangedSubviews: [timerIcon, timerTextStack])
        timerPanel.axis = .horizontal
        timerPanel.alignment = .center
        timerPanel.spacing = 8
        timerPanel.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        timerPanel.isLayoutMarginsRelativeArrangement = true
        timerPanel.backgroundColor = BeeTheme.paleHoney
        timerPanel.layer.cornerRadius = 14
        timerPanel.widthAnchor.constraint(greaterThanOrEqualToConstant: 116).isActive = true

        let topRow = UIStackView(arrangedSubviews: [titleStack, timerPanel])
        topRow.axis = .horizontal
        topRow.spacing = 14
        topRow.alignment = .center
        titleStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timerPanel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let progressStack = UIStackView(arrangedSubviews: [progressLabel, progressView])
        progressStack.axis = .vertical
        progressStack.spacing = 7

        let headerStack = UIStackView(arrangedSubviews: [topRow, progressStack])
        headerStack.axis = .vertical
        headerStack.spacing = 14
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        headerBar.addSubview(headerStack)
        view.addSubview(headerBar)
        view.addSubview(tableView)
        view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            headerBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            headerStack.topAnchor.constraint(equalTo: headerBar.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: headerBar.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: headerBar.trailingAnchor, constant: -16),
            headerStack.bottomAnchor.constraint(equalTo: headerBar.bottomAnchor, constant: -16),

            progressView.heightAnchor.constraint(equalToConstant: 6),

            tableView.topAnchor.constraint(equalTo: headerBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -8),

            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

        updateTimerLabel()
        updateProgressLabel()
    }

    private func makeBadge(text: String, icon: String) -> UILabel {
        let label = UILabel()
        let attachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        attachment.image = UIImage(systemName: icon, withConfiguration: configuration)?
            .withTintColor(BeeTheme.amber, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -1, width: 12, height: 12)

        let value = NSMutableAttributedString(attachment: attachment)
        value.append(NSAttributedString(string: "  \(text)"))
        label.attributedText = value
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = BeeTheme.muted
        label.backgroundColor = BeeTheme.paleHoney
        label.textAlignment = .center
        label.layer.cornerRadius = 11
        label.clipsToBounds = true
        label.heightAnchor.constraint(equalToConstant: 28).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 86).isActive = true
        return label
    }

    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsLeft -= 1
            self.updateTimerLabel()
            if self.secondsLeft <= 0 {
                self.timer?.invalidate()
                self.autoSubmit()
            }
            // Cảnh báo khi còn 60 giây
            if self.secondsLeft == 60 {
                self.timerLabel.textColor = BeeTheme.amber
            }
            if self.secondsLeft <= 30 {
                self.timerLabel.textColor = BeeTheme.danger
            }
        }
    }

    private func updateTimerLabel() {
        let m = secondsLeft / 60
        let s = secondsLeft % 60
        timerLabel.text = String(format: "%02d:%02d", m, s)
    }

    private func updateProgressLabel() {
        progressLabel.text = "Đã làm: \(userAnswers.count)/\(questions.count) câu"
        let total = max(questions.count, 1)
        progressView.setProgress(Float(userAnswers.count) / Float(total), animated: true)
    }

    // MARK: - Submit
    @objc private func submitTapped() {
        let unanswered = questions.count - userAnswers.count
        var message = "Bạn chắc chắn muốn nộp bài?"
        if unanswered > 0 {
            message = "Còn \(unanswered) câu chưa làm. Bạn có muốn nộp bài không?"
        }
        let alert = UIAlertController(title: "Nộp bài", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Nộp", style: .destructive) { [weak self] _ in
            self?.performSubmit()
        })
        present(alert, animated: true)
    }

    private func autoSubmit() {
        let alert = UIAlertController(title: "Hết giờ!", message: "Đề thi đã tự động nộp bài.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.performSubmit()
        })
        present(alert, animated: true)
    }

    private func performSubmit() {
        timer?.invalidate()
        submitButton.isEnabled = false

        let answers: [SubmitAnswer] = questions.enumerated().compactMap { (i, q) -> SubmitAnswer? in
                guard let ans = userAnswers[i] else { return nil }
                return SubmitAnswer(
                    questionId: q.id ?? "",
                    selectedOption: ans.option,
                    selectedText: ans.text
                )
            }

        QuizAPIService.shared.submitQuiz(id: quiz.id, answers: answers) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let quizResult):
                    let resultVC = ExamResultViewController(
                        quiz: self.quiz,
                        result: quizResult,
                        questions: self.questions,
                        userAnswers: self.userAnswers
                    )
                    resultVC.modalPresentationStyle = .fullScreen
                    self.present(resultVC, animated: true)
                case .failure:
                    self.submitButton.isEnabled = true
                    let a = UIAlertController(title: "Lỗi", message: "Nộp bài thất bại, thử lại", preferredStyle: .alert)
                    a.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(a, animated: true)
                }
            }
        }
    }
}

// MARK: - DataSource
extension TakeExamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { questions.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TakeExamQuestionCell.reuseID, for: indexPath) as! TakeExamQuestionCell
        let q = questions[indexPath.row]
        let selected = userAnswers[indexPath.row]?.option
        cell.configure(question: q, questionIndex: indexPath.row + 1, selectedOption: selected)
        // Thay đoạn cũ trong cellForRowAt
        cell.onSelectOption = { [weak self] optionIndex, _ in   // bỏ optionText từ button
            guard let self = self else { return }
            let q = self.questions[indexPath.row]
            let exactText = q.options[optionIndex]              // ← lấy text gốc từ model
            self.userAnswers[indexPath.row] = (option: optionIndex, text: exactText)
            self.updateProgressLabel()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        return cell
    }
}
