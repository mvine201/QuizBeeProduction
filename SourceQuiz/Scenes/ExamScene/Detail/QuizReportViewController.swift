//
//  QuizReportViewController.swift
//  SourceQuiz
//
//  Created by Assistant on 16/5/26.
//

import UIKit

final class QuizReportViewController: UIViewController {

    private struct ReportReason {
        let value: String
        let title: String
    }

    private let quizId: String
    private let reasons = [
        ReportReason(value: "Nội dung phản cảm", title: "Nội dung phản cảm / Không phù hợp"),
        ReportReason(value: "Sai kiến thức/đáp án", title: "Sai kiến thức / Sai đáp án nghiêm trọng"),
        ReportReason(value: "Spam/Trùng lặp", title: "Spam / Đề thi rác"),
        ReportReason(value: "Lý do khác", title: "Lý do khác"),
    ]

    private var selectedReasonIndex = 0 {
        didSet { updateReasonButton() }
    }

    private let reasonButton = UIButton(type: .system)
    private let descriptionTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let statusLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    init(quizId: String) {
        self.quizId = quizId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BeeTheme.card
        setupUI()
        updateReasonButton()
        configureKeyboardDismissal(for: [descriptionTextView])
        enableKeyboardDismissOnTap()
    }

    private func setupUI() {
        let titleLabel = BeeTheme.titleLabel("Báo cáo vi phạm", size: 24)
        let subtitleLabel = BeeTheme.bodyLabel(
            "Hãy cho chúng tôi biết vấn đề của đề thi này để xây dựng cộng đồng học tập tốt hơn."
        )

        let reasonLabel = fieldLabel("Lý do báo cáo")
        configureReasonButton()

        let descriptionLabel = fieldLabel("Chi tiết thêm")
        configureDescriptionTextView()

        BeeTheme.secondaryButton(cancelButton, title: "Hủy")
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        BeeTheme.successButton(submitButton, title: "Gửi Báo Cáo", icon: "paperplane.fill")
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statusLabel.textColor = BeeTheme.muted
        statusLabel.numberOfLines = 0

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, submitButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            reasonLabel,
            reasonButton,
            descriptionLabel,
            descriptionTextView,
            statusLabel,
            buttonStack,
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            reasonButton.heightAnchor.constraint(equalToConstant: 48),
            cancelButton.heightAnchor.constraint(equalToConstant: 48),
            submitButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    private func configureReasonButton() {
        reasonButton.contentHorizontalAlignment = .fill
        reasonButton.layer.cornerRadius = 12
        reasonButton.layer.borderWidth = 1
        reasonButton.layer.borderColor = BeeTheme.border.cgColor
        reasonButton.backgroundColor = BeeTheme.card
        reasonButton.showsMenuAsPrimaryAction = true
    }

    private func configureDescriptionTextView() {
        BeeTheme.styleTextView(descriptionTextView, minHeight: 104)
        descriptionTextView.delegate = self

        placeholderLabel.text = "Mô tả rõ hơn vấn đề bạn gặp phải (ví dụ: Câu 3 đáp án bị sai)..."
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.textColor = BeeTheme.subtleText
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 12),
            placeholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -12),
        ])
    }

    private func updateReasonButton() {
        let selectedReason = reasons[selectedReasonIndex]
        var config = UIButton.Configuration.plain()
        config.title = selectedReason.title
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseForegroundColor = BeeTheme.ink
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        reasonButton.configuration = config
        reasonButton.menu = UIMenu(children: reasons.enumerated().map { index, reason in
            UIAction(
                title: reason.title,
                state: index == selectedReasonIndex ? .on : .off
            ) { [weak self] _ in
                self?.selectedReasonIndex = index
            }
        })
    }

    private func fieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = BeeTheme.ink
        return label
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func submitTapped() {
        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !description.isEmpty else {
            statusLabel.text = "Vui lòng nhập chi tiết báo cáo."
            statusLabel.textColor = BeeTheme.danger
            return
        }

        setSubmitting(true)
        statusLabel.text = "Đang gửi báo cáo..."
        statusLabel.textColor = BeeTheme.muted

        let reason = reasons[selectedReasonIndex].value
        QuizAPIService.shared.reportQuiz(quizId: quizId, reason: reason, description: description) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let response):
                    self.statusLabel.text = response.message
                    self.statusLabel.textColor = BeeTheme.success
                    self.showCompletionAlert(message: response.message)
                case .failure(let error):
                    self.setSubmitting(false)
                    self.statusLabel.text = error.localizedDescription
                    self.statusLabel.textColor = BeeTheme.danger
                }
            }
        }
    }

    private func setSubmitting(_ isSubmitting: Bool) {
        submitButton.isEnabled = !isSubmitting
        cancelButton.isEnabled = !isSubmitting
        reasonButton.isEnabled = !isSubmitting
        descriptionTextView.isEditable = !isSubmitting
        BeeTheme.successButton(
            submitButton,
            title: isSubmitting ? "Đang gửi..." : "Gửi Báo Cáo",
            icon: isSubmitting ? nil : "paperplane.fill"
        )
    }

    private func showCompletionAlert(message: String) {
        let alert = UIAlertController(title: "Cảm ơn bạn", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

extension QuizReportViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
