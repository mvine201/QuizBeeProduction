//
//  CreateExamViewController.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import UIKit

final class CreateExamViewController: UIViewController {

    var onCreated: (() -> Void)?

    private var banks: [QuestionBank] = []
    private var selectedBank: QuestionBank?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let content    = UIView()
    private let stack      = UIStackView()

    private lazy var titleField      = makeField(placeholder: "Tên đề thi")
    private lazy var timeLimitField  = makeField(placeholder: "Thời gian (phút)", keyboard: .numberPad)
    private lazy var attemptsField   = makeField(placeholder: "Số lần làm bài (0 = không giới hạn)", keyboard: .numberPad)
    private lazy var numQField       = makeField(placeholder: "Số câu hỏi", keyboard: .numberPad)

    private lazy var bankPicker: UIPickerView = {
        let p = UIPickerView()
        p.dataSource = self
        p.delegate   = self
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()

    private lazy var shuffleQSwitch  = makeSwitch()
    private lazy var shuffleASwitch  = makeSwitch()
    private lazy var isPublicSwitch  = makeSwitch()

    private lazy var submitButton: UIButton = {
        let btn = UIButton(type: .system)
        BeeTheme.primaryButton(btn, title: "Tạo đề thi", icon: "checkmark.seal.fill")
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var bankCountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = BeeTheme.muted
        l.text = "Chọn ngân hàng câu hỏi"
        return l
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tạo Đề Thi Mới"
        view.backgroundColor = BeeTheme.cream
        setupLayout()
        fetchBanks()
    }

    // MARK: - Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        content.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14

        view.addSubview(scrollView)
        scrollView.addSubview(content)
        content.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -30),
        ])

        let hero = UILabel()
        hero.text = "🐝 Tạo đề từ kho câu hỏi"
        hero.font = .systemFont(ofSize: 24, weight: .black)
        hero.textColor = BeeTheme.ink
        hero.numberOfLines = 0
        stack.addArrangedSubview(hero)

        // Build rows
        stack.addArrangedSubview(makeLabel("Tên đề thi *"))
        stack.addArrangedSubview(titleField)

        stack.addArrangedSubview(makeLabel("Ngân hàng câu hỏi *"))
        stack.addArrangedSubview(bankCountLabel)
        stack.addArrangedSubview(bankPicker)

        stack.addArrangedSubview(makeLabel("Thời gian làm bài (phút) *"))
        stack.addArrangedSubview(timeLimitField)

        stack.addArrangedSubview(makeLabel("Số lần làm bài (0 = không giới hạn)"))
        stack.addArrangedSubview(attemptsField)

        stack.addArrangedSubview(makeLabel("Số câu hỏi cần lấy *"))
        stack.addArrangedSubview(numQField)

        // Advanced
        stack.addArrangedSubview(makeSectionHeader("Tuỳ chọn nâng cao"))
        stack.addArrangedSubview(makeSwitchRow(label: "Xáo trộn câu hỏi",  toggle: shuffleQSwitch))
        stack.addArrangedSubview(makeSwitchRow(label: "Xáo trộn đáp án",    toggle: shuffleASwitch))
        stack.addArrangedSubview(makeSwitchRow(label: "Công khai đề thi",   toggle: isPublicSwitch))

        stack.addArrangedSubview(submitButton)

        enableKeyboardDismissOnTap()
        configureKeyboardDismissal(for: [titleField, timeLimitField, attemptsField, numQField])
    }

    // MARK: - Fetch Banks
    private func fetchBanks() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let list = try await APIClient.shared.getMyBanks()
                await MainActor.run {
                    self.banks = list
                    self.bankPicker.reloadAllComponents()

                    guard let firstBank = list.first else {
                        self.selectedBank = nil
                        self.bankCountLabel.text = "Bạn chưa có ngân hàng câu hỏi"
                        return
                    }

                    self.selectedBank = firstBank
                }

                if let firstBank = list.first {
                    try await fetchBankDetail(bankID: firstBank.id)
                }
            } catch {
                await MainActor.run {
                    self.showAlert("Không thể tải danh sách ngân hàng câu hỏi")
                }
            }
        }
    }

    private func fetchBankDetail(bankID: String) async throws {
        await MainActor.run {
            self.bankCountLabel.text = "Đang tải..."
            self.numQField.text = ""
            self.numQField.placeholder = "Đang tải số câu..."
        }

        let detail = try await APIClient.shared.getBank(id: bankID)

        await MainActor.run {
            self.selectedBank = detail
            self.updateBankLabel(detail)
        }
    }

    private func updateBankLabel(_ bank: QuestionBank) {
        let count = bank.questions?.count ?? 0
        bankCountLabel.text = "Ngân hàng có \(count) câu hỏi"
        numQField.placeholder = "Số câu hỏi (tối đa \(count))"
    }

    // MARK: - Actions
    @objc private func submitTapped() {
        guard let title = titleField.text, !title.isEmpty else { return showAlert("Nhập tên đề thi") }
        guard let bank = selectedBank else { return showAlert("Chọn ngân hàng câu hỏi") }
        guard let timeLimitStr = timeLimitField.text, let timeLimit = Int(timeLimitStr), timeLimit > 0 else {
            return showAlert("Nhập thời gian làm bài hợp lệ")
        }
        guard let numQStr = numQField.text, let numQ = Int(numQStr), numQ > 0 else {
            return showAlert("Nhập số câu hỏi hợp lệ")
        }

        let bankQCount = bank.questions?.count ?? 0
        if numQ > bankQCount { return showAlert("Số câu không được vượt quá \(bankQCount) câu trong ngân hàng") }

        let attempts = Int(attemptsField.text ?? "0") ?? 0

        let params: [String: Any] = [
            "bankId": bank.id,
            "title": title,
            "timeLimit": timeLimit,
            "attemptsAllowed": attempts,
            "numQuestions": numQ,
            "mode": "random",
            "shuffleQuestions": shuffleQSwitch.isOn,
            "shuffleAnswers": shuffleASwitch.isOn,
            "isPublic": isPublicSwitch.isOn,
        ]

        submitButton.isEnabled = false
        submitButton.configuration?.title = "Đang tạo..."

        QuizAPIService.shared.generateQuizFromBank(params: params) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.submitButton.isEnabled = true
                self.submitButton.configuration?.title = "Tạo đề thi"
                switch result {
                case .success:
                    self.onCreated?()
                    self.navigationController?.popViewController(animated: true)
                case .failure:
                    self.showAlert("Tạo đề thi thất bại")
                }
            }
        }
    }

    // MARK: - Helpers
    private func makeField(placeholder: String, keyboard: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.keyboardType = keyboard
        BeeTheme.styleField(tf)
        return tf
    }

    private func makeLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = BeeTheme.ink
        return l
    }

    private func makeSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = BeeTheme.amber
        return l
    }

    private func makeSwitch() -> UISwitch {
        let s = UISwitch()
        s.onTintColor = BeeTheme.honey
        return s
    }

    private func makeSwitchRow(label: String, toggle: UISwitch) -> UIView {
        let lbl = UILabel()
        lbl.text = label
        lbl.font = .systemFont(ofSize: 15)
        let row = UIStackView(arrangedSubviews: [lbl, toggle])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    private func showAlert(_ msg: String) {
        let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - PickerView
extension CreateExamViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { banks.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { banks[row].title }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = banks[row]
        selectedBank = selected

        Task { [weak self] in
            guard let self else { return }

            do {
                try await self.fetchBankDetail(bankID: selected.id)
            } catch {
                await MainActor.run {
                    self.showAlert("Không thể tải chi tiết ngân hàng câu hỏi")
                }
            }
        }
    }
}
