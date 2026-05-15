import UIKit

final class QuestionDetailTCell: UITableViewCell {

    static let reuseID = "QuestionDetailTCell"

    // MARK: - UI Elements

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyCard(v, radius: 12)
        return v
    }()

    private let headerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = BeeTheme.amber
        return l
    }()

    private let questionBox: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyOutlinedSurface(v, radius: 10)
        return v
    }()

    private let questionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = BeeTheme.ink
        l.numberOfLines = 0
        return l
    }()

    // 4 option buttons stacked vertically
    private var optionButtons: [OptionButton] = []
    private let optionsStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 10
        sv.distribution = .fill
        return sv
    }()

    private var correctAnswer: Int = 0

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        buildOptions()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build

    private func buildOptions() {
        for _ in 0..<4 {
            let btn = OptionButton()
            btn.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionButtons.append(btn)
            optionsStack.addArrangedSubview(btn)
        }
    }

    private func setupLayout() {
        contentView.addSubview(cardView)

        [headerLabel, questionBox, optionsStack].forEach { cardView.addSubview($0) }
        questionBox.addSubview(questionLabel)

        NSLayoutConstraint.activate([
            // Card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            // Header
            headerLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // Question box
            questionBox.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            questionBox.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            questionBox.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // Question label inside box
            questionLabel.topAnchor.constraint(equalTo: questionBox.topAnchor, constant: 12),
            questionLabel.leadingAnchor.constraint(equalTo: questionBox.leadingAnchor, constant: 12),
            questionLabel.trailingAnchor.constraint(equalTo: questionBox.trailingAnchor, constant: -12),
            questionLabel.bottomAnchor.constraint(equalTo: questionBox.bottomAnchor, constant: -12),

            // Options stack
            optionsStack.topAnchor.constraint(equalTo: questionBox.bottomAnchor, constant: 14),
            optionsStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            optionsStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            optionsStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Configure

    func configure(with question: Question, questionIndex: Int) {
        correctAnswer = question.correctAnswer ?? -1
        headerLabel.text = "Câu hỏi \(questionIndex)"
        questionLabel.text = question.questionText

        for (i, btn) in optionButtons.enumerated() {
            let text = i < question.options.count ? question.options[i] : ""
            let isCorrect = (i == question.correctAnswer ?? -1)
            btn.configure(title: text, isSelected: isCorrect)
        }
    }

    // MARK: - Actions

    @objc private func optionTapped(_ sender: OptionButton) {
        // Highlight tapped; keep correct answer always highlighted if desired
        optionButtons.forEach { $0.setChoiceSelected(false) }
        sender.setChoiceSelected(true)
    }
}
