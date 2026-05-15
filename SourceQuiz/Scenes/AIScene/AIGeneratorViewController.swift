import UIKit
import UniformTypeIdentifiers

enum AIGeneratorMode {
    case quiz
    case bank
}

final class AIGeneratorViewController: UIViewController, UIDocumentPickerDelegate {
    var onSaved: (() -> Void)?

    private let mode: AIGeneratorMode
    private var questions: [Question] = []
    private var selectedFileData: Data?
    private var selectedFileName: String?

    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let previewStack = UIStackView()
    private let sourceControl = UISegmentedControl(items: ["Chủ đề", "Tài liệu"])
    private let topicField = UITextField()
    private let countField = UITextField()
    private let fileButton = UIButton(type: .system)
    private let generateButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let titleField = UITextField()
    private let descriptionField = UITextField()
    private let timeField = UITextField()
    private let attemptsField = UITextField()
    private let publicSwitch = UISwitch()
    private let shuffleQuestionSwitch = UISwitch()
    private let shuffleAnswerSwitch = UISwitch()
    private let spinner = UIActivityIndicatorView(style: .medium)

    init(mode: AIGeneratorMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = mode == .quiz ? "Tạo đề thi AI" : "Tạo ngân hàng AI"
        view.backgroundColor = BeeTheme.cream
        setupUI()
        renderPreview()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 18

        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30),
        ])

        sourceControl.selectedSegmentIndex = 0
        sourceControl.selectedSegmentTintColor = BeeTheme.honey
        sourceControl.addTarget(self, action: #selector(sourceChanged), for: .valueChanged)

        topicField.placeholder = "VD: Sinh học tế bào, lịch sử Việt Nam..."
        countField.placeholder = "Số câu hỏi"
        countField.text = "10"
        countField.keyboardType = .numberPad
        [topicField, countField, titleField, descriptionField, timeField, attemptsField].forEach {
            BeeTheme.styleField($0)
        }

        titleField.placeholder = mode == .quiz ? "Tên đề thi" : "Tên ngân hàng câu hỏi"
        descriptionField.placeholder = "Mô tả ngắn"
        timeField.placeholder = "Thời gian làm bài (phút)"
        timeField.text = "15"
        timeField.keyboardType = .numberPad
        attemptsField.placeholder = "Số lần làm bài (0 = không giới hạn)"
        attemptsField.text = "1"
        attemptsField.keyboardType = .numberPad

        BeeTheme.primaryButton(fileButton, title: "Chọn file PDF/DOCX", icon: "doc.badge.plus")
        fileButton.addTarget(self, action: #selector(pickFile), for: .touchUpInside)

        BeeTheme.primaryButton(generateButton, title: "Nhờ Bee AI tạo câu hỏi", icon: "sparkles")
        generateButton.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)

        BeeTheme.primaryButton(saveButton, title: mode == .quiz ? "Lưu đề thi" : "Lưu ngân hàng", icon: "tray.and.arrow.down.fill")
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = BeeTheme.muted
        statusLabel.numberOfLines = 0

        previewStack.axis = .vertical
        previewStack.spacing = 12

        stack.addArrangedSubview(makeHeroCard())
        stack.addArrangedSubview(makeAICard())
        stack.addArrangedSubview(makeSaveCard())
        stack.addArrangedSubview(makePreviewCard())

        enableKeyboardDismissOnTap()
        configureKeyboardDismissal(for: [
            topicField,
            countField,
            titleField,
            descriptionField,
            timeField,
            attemptsField,
        ])
    }

    private func makeHeroCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        let icon = UILabel()
        icon.text = "🐝"
        icon.font = .systemFont(ofSize: 38)

        let titleLabel = UILabel()
        titleLabel.text = mode == .quiz ? "Bee AI soạn đề thi" : "Bee AI xây kho câu hỏi"
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = BeeTheme.ink
        titleLabel.numberOfLines = 0

        let subtitle = UILabel()
        subtitle.text = "Nhập chủ đề hoặc tải tài liệu PDF/DOCX. Bee AI sẽ tạo câu hỏi trắc nghiệm tiếng Việt để bạn kiểm tra lại và lưu."
        subtitle.font = .systemFont(ofSize: 14)
        subtitle.textColor = BeeTheme.muted
        subtitle.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitle])
        textStack.axis = .vertical
        textStack.spacing = 6

        let row = UIStackView(arrangedSubviews: [icon, textStack])
        row.axis = .horizontal
        row.spacing = 14
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    private func makeAICard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        let title = makeSectionTitle("1. Dữ liệu cho AI")
        let formStack = UIStackView(arrangedSubviews: [
            title,
            sourceControl,
            topicField,
            fileButton,
            countField,
            generateButton,
            spinner,
            statusLabel,
        ])
        formStack.axis = .vertical
        formStack.spacing = 12
        formStack.translatesAutoresizingMaskIntoConstraints = false

        spinner.hidesWhenStopped = true
        fileButton.isHidden = true

        card.addSubview(formStack)
        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            formStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            formStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            formStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    private func makeSaveCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        let title = makeSectionTitle("2. Cấu hình lưu")
        var arranged: [UIView] = [title, titleField, descriptionField]
        if mode == .quiz {
            arranged.append(timeField)
            arranged.append(attemptsField)
            arranged.append(makeSwitchRow(text: "Công khai đề thi", control: publicSwitch))
            arranged.append(makeSwitchRow(text: "Xáo trộn câu hỏi", control: shuffleQuestionSwitch))
            arranged.append(makeSwitchRow(text: "Xáo trộn đáp án", control: shuffleAnswerSwitch))
        }
        arranged.append(saveButton)

        let formStack = UIStackView(arrangedSubviews: arranged)
        formStack.axis = .vertical
        formStack.spacing = 12
        formStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(formStack)
        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            formStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            formStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            formStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    private func makePreviewCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        let title = makeSectionTitle("3. Xem trước câu hỏi")
        let content = UIStackView(arrangedSubviews: [title, previewStack])
        content.axis = .vertical
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    @objc private func sourceChanged() {
        let isTopic = sourceControl.selectedSegmentIndex == 0
        topicField.isHidden = !isTopic
        fileButton.isHidden = isTopic
    }

    @objc private func pickFile() {
        var types: [UTType] = []
        if let pdf = UTType(filenameExtension: "pdf") { types.append(pdf) }
        if let docx = UTType(filenameExtension: "docx") { types.append(docx) }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        do {
            let data = try Data(contentsOf: url)
            guard data.count <= 5 * 1024 * 1024 else {
                return showAlert("File không được vượt quá 5MB")
            }
            selectedFileData = data
            selectedFileName = url.lastPathComponent
            BeeTheme.primaryButton(fileButton, title: url.lastPathComponent, icon: "doc.fill")
        } catch {
            showAlert("Không thể đọc file: \(error.localizedDescription)")
        }
    }

    @objc private func generateTapped() {
        let count = Int(countField.text ?? "") ?? 10
        guard count > 0 && count <= 100 else { return showAlert("Số câu hỏi phải từ 1 đến 100") }

        generateButton.isEnabled = false
        spinner.startAnimating()
        statusLabel.text = "Bee AI đang phân tích dữ liệu..."
        questions.removeAll()
        renderPreview()

        Task { [weak self] in
            guard let self else { return }
            do {
                let generated: [Question]
                if self.sourceControl.selectedSegmentIndex == 0 {
                    let topic = self.topicField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    guard !topic.isEmpty else { throw APIError.server("Vui lòng nhập chủ đề") }
                    generated = try await APIClient.shared.generateAIQuestions(topic: topic, numQuestions: count)
                    await MainActor.run {
                        self.titleField.text = self.mode == .quiz ? "Đề thi AI: \(topic)" : "Ngân hàng AI: \(topic)"
                        self.descriptionField.text = "Tạo tự động bởi Quiz Bee AI với \(count) câu hỏi."
                    }
                } else {
                    guard let data = self.selectedFileData, let name = self.selectedFileName else {
                        throw APIError.server("Vui lòng chọn file PDF hoặc DOCX")
                    }
                    generated = try await APIClient.shared.generateAIQuestions(fileData: data, fileName: name, numQuestions: count)
                    await MainActor.run {
                        self.titleField.text = self.mode == .quiz ? "Đề thi AI từ tài liệu" : "Ngân hàng AI từ tài liệu"
                        self.descriptionField.text = "Tạo tự động bởi Quiz Bee AI từ \(name)."
                    }
                }

                await MainActor.run {
                    self.questions = generated
                    self.statusLabel.text = "Đã tạo \(generated.count) câu hỏi. Hãy kiểm tra lại trước khi lưu."
                    self.generateButton.isEnabled = true
                    self.spinner.stopAnimating()
                    self.renderPreview()
                }
            } catch {
                await MainActor.run {
                    self.generateButton.isEnabled = true
                    self.spinner.stopAnimating()
                    self.statusLabel.text = error.localizedDescription
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    @objc private func saveTapped() {
        guard !questions.isEmpty else { return showAlert("Chưa có câu hỏi nào để lưu") }
        let name = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else { return showAlert("Vui lòng nhập tiêu đề") }

        saveButton.isEnabled = false
        Task { [weak self] in
            guard let self else { return }
            do {
                if self.mode == .quiz {
                    let time = Int(self.timeField.text ?? "") ?? 15
                    let attempts = Int(self.attemptsField.text ?? "") ?? 0
                    _ = try await APIClient.shared.createQuiz(
                        title: name,
                        description: self.descriptionField.text,
                        timeLimit: max(time, 1),
                        attemptsAllowed: max(attempts, 0),
                        isPublic: self.publicSwitch.isOn,
                        shuffleQuestions: self.shuffleQuestionSwitch.isOn,
                        shuffleAnswers: self.shuffleAnswerSwitch.isOn,
                        questions: self.questions
                    )
                } else {
                    _ = try await APIClient.shared.createBank(
                        title: name,
                        description: self.descriptionField.text,
                        questions: self.questions
                    )
                }

                await MainActor.run {
                    self.onSaved?()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.saveButton.isEnabled = true
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    private func renderPreview() {
        previewStack.arrangedSubviews.forEach { view in
            previewStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        if questions.isEmpty {
            let empty = UILabel()
            empty.text = "Chưa có câu hỏi. Nhập dữ liệu để Bee AI bắt đầu làm việc."
            empty.font = .systemFont(ofSize: 14, weight: .medium)
            empty.textColor = BeeTheme.muted
            empty.numberOfLines = 0
            previewStack.addArrangedSubview(empty)
            return
        }

        for (index, question) in questions.enumerated() {
            previewStack.addArrangedSubview(makeQuestionPreview(question, index: index))
        }
    }

    private func makeQuestionPreview(_ question: Question, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = BeeTheme.cream
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.92, green: 0.82, blue: 0.55, alpha: 1).cgColor

        let title = UILabel()
        title.text = "Câu \(index + 1): \(question.questionText)"
        title.font = .systemFont(ofSize: 15, weight: .bold)
        title.textColor = BeeTheme.ink
        title.numberOfLines = 0

        let optionText = question.options.enumerated().map { idx, value in
            let prefix = ["A", "B", "C", "D"][safe: idx] ?? "\(idx + 1)"
            let marker = idx == question.correctAnswer ? " ✓" : ""
            return "\(prefix). \(value)\(marker)"
        }.joined(separator: "\n")

        let options = UILabel()
        options.text = optionText
        options.font = .systemFont(ofSize: 14)
        options.textColor = BeeTheme.muted
        options.numberOfLines = 0

        let content = UIStackView(arrangedSubviews: [title, options])
        content.axis = .vertical
        content.spacing = 8
        content.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
        ])
        return card
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .black)
        label.textColor = BeeTheme.ink
        return label
    }

    private func makeSwitchRow(text: String, control: UISwitch) -> UIView {
        control.onTintColor = BeeTheme.honey
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = BeeTheme.ink
        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        return row
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Quiz Bee", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
