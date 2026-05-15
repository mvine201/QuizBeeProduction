//
//  OptionButton.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 17/4/26.
//

import UIKit

final class OptionButton: UIControl {

    private let radioView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 11
        v.layer.borderWidth = 1.5
        v.layer.borderColor = BeeTheme.border.cgColor
        v.backgroundColor = BeeTheme.card
        return v
    }()

    private let innerDot: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 6
        v.backgroundColor = BeeTheme.card
        v.isHidden = true
        return v
    }()

    internal let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = BeeTheme.ink
        l.numberOfLines = 0
        return l
    }()

    // Selected state colors
    private let selectedBorderColor = BeeTheme.amber
    private let selectedBgColor = BeeTheme.softHoney

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        layer.borderWidth = 1.5
        layer.borderColor = BeeTheme.border.cgColor
        backgroundColor = BeeTheme.card
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

        radioView.addSubview(innerDot)
        addSubview(radioView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            radioView.widthAnchor.constraint(equalToConstant: 22),
            radioView.heightAnchor.constraint(equalToConstant: 22),
            radioView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            radioView.centerYAnchor.constraint(equalTo: centerYAnchor),

            innerDot.widthAnchor.constraint(equalToConstant: 12),
            innerDot.heightAnchor.constraint(equalToConstant: 12),
            innerDot.centerXAnchor.constraint(equalTo: radioView.centerXAnchor),
            innerDot.centerYAnchor.constraint(equalTo: radioView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: radioView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        setChoiceSelected(isSelected)
    }

    func setChoiceSelected(_ selected: Bool) {
        if selected {
            backgroundColor = selectedBgColor
            layer.borderColor = selectedBorderColor.cgColor
            radioView.backgroundColor = selectedBorderColor
            radioView.layer.borderColor = selectedBorderColor.cgColor
            titleLabel.textColor = BeeTheme.ink
            innerDot.isHidden = false
        } else {
            backgroundColor = BeeTheme.card
            layer.borderColor = BeeTheme.border.cgColor
            radioView.backgroundColor = BeeTheme.card
            radioView.layer.borderColor = BeeTheme.border.cgColor
            titleLabel.textColor = BeeTheme.ink
            innerDot.isHidden = true
        }
    }
}
