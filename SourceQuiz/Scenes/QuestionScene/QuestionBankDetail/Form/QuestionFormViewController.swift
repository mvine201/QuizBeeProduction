import UIKit

final class QuestionFormViewController: UIViewController {

    // MARK: - Mode
    enum Mode {
        case add
        case edit(Question)
    }

    private let mode: Mode
    private let onSave: (Question) -> Void

    init(mode: Mode, onSave: @escaping (Question) -> Void) {
        self.mode = mode
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let questionTextView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private var optionFields: [UITextField] = []
    private let optionLabels = ["A", "B", "C", "D"]

    private let correctAnswerLabel: UILabel = {
        let l = UILabel()
        l.text = "Đáp án đúng"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = BeeTheme.ink
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var correctAnswerSegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["A", "B", "C", "D"])
        sc.selectedSegmentIndex = 0
        BeeTheme.styleSegment(sc)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        BeeTheme.applyAppBackground(view)
        title = mode.isEdit ? "Sửa câu hỏi" : "Thêm câu hỏi"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Huỷ", style: .plain, target: self, action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Lưu", style: .prominent, target: self, action: #selector(saveTapped)
        )

        setupLayout()
        fillDataIfEditing()
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        contentView.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.styleTextView(questionTextView, minHeight: 88)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])

        // Question text
        stackView.addArrangedSubview(makeLabel("Nội dung câu hỏi"))
        stackView.addArrangedSubview(questionTextView)

        // Options
        stackView.addArrangedSubview(makeLabel("Các lựa chọn"))
        for i in 0..<4 {
            let field = makeOptionField(placeholder: "Đáp án \(optionLabels[i])")
            optionFields.append(field)
            let row = makeOptionRow(label: optionLabels[i], field: field)
            stackView.addArrangedSubview(row)
        }

        // Correct answer
        stackView.addArrangedSubview(correctAnswerLabel)
        stackView.addArrangedSubview(correctAnswerSegment)

        enableKeyboardDismissOnTap()
        configureKeyboardDismissal(for: [questionTextView] + optionFields)
    }

    private func makeLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = BeeTheme.ink
        return l
    }

    private func makeOptionField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        BeeTheme.styleField(tf)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }

    private func makeOptionRow(label: String, field: UITextField) -> UIView {
        let badge = UILabel()
        badge.text = label
        badge.font = .systemFont(ofSize: 14, weight: .bold)
        badge.textColor = BeeTheme.ink
        badge.backgroundColor = BeeTheme.honey
        badge.textAlignment = .center
        badge.layer.cornerRadius = 15
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.widthAnchor.constraint(equalToConstant: 30).isActive = true
        badge.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let row = UIStackView(arrangedSubviews: [badge, field])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        return row
    }

    // MARK: - Fill data (edit mode)

    private func fillDataIfEditing() {
        if case .edit(let question) = mode {
            questionTextView.text = question.questionText
            for (i, option) in question.options.enumerated() {
                optionFields[safe: i]?.text = option
            }
            correctAnswerSegment.selectedSegmentIndex = question.correctAnswer ?? -1
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let questionText = questionTextView.text, !questionText.isEmpty else {
            showAlert("Vui lòng nhập nội dung câu hỏi")
            return
        }

        let options = optionFields.map { $0.text ?? "" }
        if options.contains(where: { $0.isEmpty }) {
            showAlert("Vui lòng nhập đầy đủ 4 đáp án")
            return
        }

        let existingQuestion: Question? = {
            if case .edit(let question) = mode {
                return question
            }
            return nil
        }()

        let question = Question(
            id: existingQuestion?.id,
            questionText: questionText,
            options: options,
            correctAnswer: correctAnswerSegment.selectedSegmentIndex,
            points: existingQuestion?.points ?? 10
        )

        onSave(question)
        dismiss(animated: true)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Mode Helper

extension QuestionFormViewController.Mode {
    var isEdit: Bool {
        if case .edit = self { return true }
        return false
    }
}

// MARK: - Array safe subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
