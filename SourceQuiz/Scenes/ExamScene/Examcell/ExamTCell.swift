//
//  ExamTCell.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import UIKit

final class ExamTCell: UITableViewCell {
    static let reuseID = "ExamTCell"

    var onTake: (() -> Void)?
    var onDelete: (() -> Void)?

    // MARK: - UI
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyCard(v)
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = BeeTheme.ink
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.layer.cornerRadius = 8
        l.clipsToBounds = true
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var infoStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [questionCountLabel, timeLimitLabel, attemptsLabel])
        sv.axis = .vertical
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let questionCountLabel = ExamTCell.infoChip()
    private let timeLimitLabel     = ExamTCell.infoChip()
    private let attemptsLabel      = ExamTCell.infoChip()

    private lazy var buttonStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [takeButton, deleteButton])
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var takeButton   = makeActionButton(title: "Chi tiết", color: BeeTheme.honey, icon: "doc.text.magnifyingglass")
    private lazy var deleteButton = makeActionButton(title: "Xoá",     color: BeeTheme.danger, icon: "trash")

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupLayout()
        takeButton.addTarget(self,   action: #selector(takeTapped),   for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout
    private func setupLayout() {
        contentView.addSubview(cardView)
        [titleLabel, statusBadge, infoStack, buttonStack].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: -10),

            statusBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),

            infoStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            infoStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            infoStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            buttonStack.topAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: 14),
            buttonStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 42),
        ])
    }

    // MARK: - Configure
    func configure(with quiz: Quiz) {
        titleLabel.text = quiz.title
        statusBadge.text = quiz.isApproved ? " Đã duyệt " : " Chờ duyệt "
        statusBadge.backgroundColor = quiz.isApproved ? BeeTheme.success : BeeTheme.amber
        setChip(questionCountLabel, icon: "questionmark.circle.fill", text: "\(quiz.questionCount) câu hỏi")
        setChip(timeLimitLabel, icon: "clock.fill", text: "\(quiz.timeLimit) phút làm bài")
        let attempts = quiz.attemptsAllowed == 0 ? "Không giới hạn" : "\(quiz.attemptsAllowed) lần"
        setChip(attemptsLabel, icon: "arrow.clockwise", text: "Lượt làm: \(attempts)")
    }

    private func setChip(_ label: UILabel, icon: String, text: String) {
        let attachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        attachment.image = UIImage(systemName: icon, withConfiguration: configuration)?
            .withTintColor(BeeTheme.amber, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        let value = NSMutableAttributedString(attachment: attachment)
        value.append(NSAttributedString(string: "  \(text)"))
        label.attributedText = value
    }

    // MARK: - Factory
    private static func infoChip() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = BeeTheme.muted
        l.numberOfLines = 1
        return l
    }

    private func makeActionButton(title: String, color: UIColor, icon: String) -> UIButton {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePadding = 4
        config.cornerStyle = .medium
        config.baseBackgroundColor = color
        config.baseForegroundColor = color == BeeTheme.honey ? BeeTheme.ink : .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        btn.configuration = config
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        return btn
    }

    // MARK: - Actions
    @objc private func takeTapped()   { onTake?() }
    @objc private func deleteTapped() { onDelete?() }
}
