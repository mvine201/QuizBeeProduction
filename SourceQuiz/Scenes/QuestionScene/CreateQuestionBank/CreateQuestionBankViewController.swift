import UIKit
import UniformTypeIdentifiers

final class CreateQuestionBankViewController: UIViewController, UIDocumentPickerDelegate {
    // Public callback when a bank is created successfully
    var onBankCreated: ((QuestionBank) -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let titleField = UITextField()
    private let descriptionField = UITextField()
    private let fileButton = UIButton(type: .system)
    private let previewLabel = UILabel()
    private let createButton = UIButton(type: .system)

    private var parsedQuestions: [Question] = []
    private var selectedFileName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tạo ngân hàng"
        view.backgroundColor = BeeTheme.cream
        setupUI()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)
        ])

        let hero = UILabel()
        hero.text = "🐝 Tạo kho câu hỏi từ file"
        hero.font = .systemFont(ofSize: 24, weight: .black)
        hero.textColor = BeeTheme.ink
        hero.numberOfLines = 0

        let titleLabel = UILabel()
        titleLabel.text = "Tiêu đề"
        titleLabel.font = .preferredFont(forTextStyle: .headline)

        titleField.placeholder = "Nhập tiêu đề ngân hàng"
        BeeTheme.styleField(titleField)

        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Mô tả"
        descriptionLabel.font = .preferredFont(forTextStyle: .headline)

        descriptionField.placeholder = "Nhập mô tả (không bắt buộc)"
        BeeTheme.styleField(descriptionField)

        // File button
        BeeTheme.primaryButton(fileButton, title: "Chọn file DOCX/TXT/XLSX", icon: "doc.badge.plus")
        fileButton.addTarget(self, action: #selector(pickFile), for: .touchUpInside)

        // Preview label
        previewLabel.text = "Chưa chọn file"
        previewLabel.textColor = BeeTheme.muted
        previewLabel.font = .systemFont(ofSize: 14, weight: .medium)
        previewLabel.numberOfLines = 0

        // Create button
        BeeTheme.primaryButton(createButton, title: "Lưu ngân hàng", icon: "tray.and.arrow.down.fill")
        createButton.addTarget(self, action: #selector(createBankTapped), for: .touchUpInside)

        let card = UIView()
        BeeTheme.applyCard(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        let cardStack = UIStackView(arrangedSubviews: [
            hero,
            titleLabel,
            titleField,
            descriptionLabel,
            descriptionField,
            fileButton,
            previewLabel,
            createButton,
        ])
        cardStack.axis = .vertical
        cardStack.spacing = 14
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardStack)
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
        ])
        contentStack.addArrangedSubview(card)

        enableKeyboardDismissOnTap()
        configureKeyboardDismissal(for: [titleField, descriptionField])
    }

    @objc private func pickFile() {
        var supported: [UTType] = [.plainText]
        if let docx = UTType(filenameExtension: "docx") { supported.append(docx) }
        if let doc = UTType(filenameExtension: "doc") { supported.append(doc) }
        if let xlsx = UTType(filenameExtension: "xlsx") { supported.append(xlsx) }
        if let xls = UTType(filenameExtension: "xls") { supported.append(xls) }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supported, asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedFileName = url.lastPathComponent
        do {
            let data = try Data(contentsOf: url)
            Task { [weak self] in
                guard let self else { return }
                do {
                    let questions = try await APIClient.shared.parseFilePreview(fileData: data, fileName: url.lastPathComponent)
                    self.parsedQuestions = questions
                    DispatchQueue.main.async {
                        self.previewLabel.text = "Đã phân tích: \(questions.count) câu hỏi từ \(url.lastPathComponent)"
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.previewLabel.text = "Lỗi phân tích file: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            previewLabel.text = "Không thể đọc file: \(error.localizedDescription)"
        }
    }

    @objc private func createBankTapped() {
        guard let titleText = titleField.text, !titleText.isEmpty else {
            showAlert(message: "Vui lòng nhập tiêu đề")
            return
        }
        let desc = descriptionField.text
        let questions = parsedQuestions

        Task { [weak self] in
            do {
                let bank = try await APIClient.shared.createBank(title: titleText, description: desc, questions: questions)
                await MainActor.run {
                    self?.onBankCreated?(bank)
                    self?.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
