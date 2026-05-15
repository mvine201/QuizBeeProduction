//
//  TakeExamQuestionCell.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import UIKit

final class TakeExamQuestionCell: UITableViewCell {
    static let reuseID = "TakeExamQuestionCell"

    var onSelectOption: ((Int, String) -> Void)?
    private var optionButtons: [OptionButton] = []

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyCard(v)
        return v
    }()

    private let indexLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = BeeTheme.ink
        l.backgroundColor = BeeTheme.paleHoney
        l.textAlignment = .center
        l.layer.cornerRadius = 11
        l.clipsToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let questionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = BeeTheme.ink
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let optionsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        [indexLabel, questionLabel, optionsStack].forEach { cardView.addSubview($0) }

        for _ in 0..<4 {
            let btn = OptionButton()
            btn.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionButtons.append(btn)
            optionsStack.addArrangedSubview(btn)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            indexLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            indexLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            indexLabel.heightAnchor.constraint(equalToConstant: 28),
            indexLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),

            questionLabel.topAnchor.constraint(equalTo: indexLabel.bottomAnchor, constant: 12),
            questionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            optionsStack.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            optionsStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            optionsStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            optionsStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(question: Question, questionIndex: Int, selectedOption: Int?) {
        indexLabel.text = "  Câu \(questionIndex)  "
        questionLabel.text = question.questionText
        for (i, btn) in optionButtons.enumerated() {
            let text = i < question.options.count ? question.options[i] : ""
            btn.isHidden = i >= question.options.count
            btn.configure(title: text, isSelected: selectedOption == i)
            btn.tag = i
        }
    }

    @objc private func optionTapped(_ sender: OptionButton) {
        let idx = sender.tag
        optionButtons.forEach { $0.setChoiceSelected(false) }
        sender.setChoiceSelected(true)
        let text = (optionsStack.arrangedSubviews[idx] as? OptionButton) != nil
        ? (sender.titleLabel.text ?? "") : ""
        onSelectOption?(idx, text)
    }
}
