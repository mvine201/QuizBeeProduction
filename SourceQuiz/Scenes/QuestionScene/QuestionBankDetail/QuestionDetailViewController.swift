import UIKit

final class QuestionDetailViewController: UIViewController {

    // MARK: - Properties
    private let bank: QuestionBank
    private var questions: [Question] = []
    private var isSelectMode = false
    private var selectedIndexes: Set<Int> = []

    init(bank: QuestionBank) {
        self.bank = bank
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = BeeTheme.cream
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 90, right: 0)
        tv.register(QuestionDetailTCell.self, forCellReuseIdentifier: QuestionDetailTCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 300
        return tv
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()

    private lazy var deleteSelectedButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.destructiveButton(btn, title: "Chọn câu hỏi cần xoá", icon: "trash.fill")
        btn.isHidden = true
        btn.addTarget(self, action: #selector(deleteSelectedTapped), for: .touchUpInside)
        return btn
    }()

    private var deleteButtonBottom: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = bank.title
        BeeTheme.applyAppBackground(view)
        setupNavBar()
        setupLayout()
        fetchBankDetail()
    }

    // MARK: - Setup

    private func setupNavBar() {
        let addBtn = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"),
                                    style: .plain, target: self, action: #selector(addQuestion))
        let selectBtn = UIBarButtonItem(title: "Chọn", style: .plain,
                                       target: self, action: #selector(toggleSelectMode))
        addBtn.tintColor = BeeTheme.amber
        selectBtn.tintColor = BeeTheme.amber
        navigationItem.rightBarButtonItems = [addBtn, selectBtn]
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(deleteSelectedButton)

        deleteButtonBottom = deleteSelectedButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 80
        )

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            deleteSelectedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteSelectedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteSelectedButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButtonBottom
        ])
    }

    // MARK: - Fetch

    private func fetchBankDetail() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true

        Task { [weak self] in
            guard let self else { return }

            do {
                let fetchedBank = try await APIClient.shared.getBank(id: bank.id)
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = false
                    self.questions = fetchedBank.questions ?? []
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = false
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }


    // MARK: - Save to Server (PUT)

    private func saveToServer(completion: ((Bool) -> Void)? = nil) {
        Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await APIClient.shared.updateBank(id: bank.id, questions: questions)
                await MainActor.run {
                    completion?(true)
                }
            } catch {
                await MainActor.run {
                    self.showError(message: "Lưu thất bại, thử lại")
                    completion?(false)
                }
            }
        }
    }

    // MARK: - Actions

    @objc private func addQuestion() {
        let formVC = QuestionFormViewController(mode: .add) { [weak self] newQuestion in
            self?.questions.append(newQuestion)
            self?.tableView.reloadData()
            self?.saveToServer()
        }
        let nav = UINavigationController(rootViewController: formVC)
        present(nav, animated: true)
    }

    @objc private func toggleSelectMode() {
        isSelectMode.toggle()
        selectedIndexes.removeAll()

        let rightItem = navigationItem.rightBarButtonItems?[1]
        rightItem?.title = isSelectMode ? "Xong" : "Chọn"

        // Hiện/ẩn nút xoá
        showDeleteButton(isSelectMode)
        tableView.reloadData()
    }

    @objc private func deleteSelectedTapped() {
        guard !selectedIndexes.isEmpty else { return }

        let alert = UIAlertController(
            title: "Xoá câu hỏi",
            message: "Xoá \(selectedIndexes.count) câu hỏi đã chọn?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xoá", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.questions = self.questions.enumerated()
                .filter { !self.selectedIndexes.contains($0.offset) }
                .map { $0.element }
            self.selectedIndexes.removeAll()
            self.tableView.reloadData()
            self.saveToServer()
            self.toggleSelectMode()
        })
        present(alert, animated: true)
    }

    private func showDeleteButton(_ show: Bool) {
        deleteSelectedButton.isHidden = !show
        deleteButtonBottom.constant = show ? -12 : 80
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        updateDeleteButtonTitle()
    }

    private func updateDeleteButtonTitle() {
        let count = selectedIndexes.count
        deleteSelectedButton.configuration?.title = count > 0 ? "Xoá (\(count) câu hỏi)" : "Chọn câu hỏi cần xoá"
        deleteSelectedButton.isEnabled = count > 0
        deleteSelectedButton.alpha = count > 0 ? 1.0 : 0.5
    }

    // MARK: - Helpers

    private func showError(message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension QuestionDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: QuestionDetailTCell.reuseID, for: indexPath
        ) as! QuestionDetailTCell

        _ = selectedIndexes.contains(indexPath.row)
        cell.configure(with: questions[indexPath.row],
                       questionIndex: indexPath.row + 1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelectMode {
            // Toggle checkbox
            if selectedIndexes.contains(indexPath.row) {
                selectedIndexes.remove(indexPath.row)
            } else {
                selectedIndexes.insert(indexPath.row)
            }
            updateDeleteButtonTitle()
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            // Mở form edit
            let question = questions[indexPath.row]
            let formVC = QuestionFormViewController(mode: .edit(question)) { [weak self] updated in
                self?.questions[indexPath.row] = updated
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                self?.saveToServer()
            }
            let nav = UINavigationController(rootViewController: formVC)
            present(nav, animated: true)
        }
    }

    // Swipe to delete (khi không ở select mode)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        guard !isSelectMode else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Xoá") { [weak self] _, _, done in
            guard let self else { return }
            self.questions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveToServer()
            done(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let editAction = UIContextualAction(style: .normal, title: "Sửa") { [weak self] _, _, done in
            guard let self else { return }
            let question = self.questions[indexPath.row]
            let formVC = QuestionFormViewController(mode: .edit(question)) { updated in
                self.questions[indexPath.row] = updated
                tableView.reloadRows(at: [indexPath], with: .automatic)
                self.saveToServer()
            }
            let nav = UINavigationController(rootViewController: formVC)
            self.present(nav, animated: true)
            done(true)
        }
        editAction.backgroundColor = BeeTheme.amber
        editAction.image = UIImage(systemName: "pencil")

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}
