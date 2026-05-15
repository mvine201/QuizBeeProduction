//
//  ExamViewController.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 17/4/26.
//

import UIKit

final class ExamViewController: UIViewController {

    private var quizzes: [Quiz] = []

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = BeeTheme.cream
        tv.register(ExamTCell.self, forCellReuseIdentifier: ExamTCell.reuseID)
        tv.dataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 180
        return tv
    }()

    private lazy var emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Chưa có đề thi nào\nTạo từ ngân hàng câu hỏi hoặc nhờ ong AI soạn đề."
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = BeeTheme.muted
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Đề thi"
        view.backgroundColor = BeeTheme.cream
        setupNavBar()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyQuizzes()
    }

    // MARK: - Setup
    private func setupNavBar() {
        let bankAction = UIAction(title: "Tạo từ ngân hàng", image: UIImage(systemName: "folder.badge.plus")) { [weak self] _ in
            self?.createExamTapped()
        }
        let aiAction = UIAction(title: "Tạo bằng AI", image: UIImage(systemName: "sparkles")) { [weak self] _ in
            self?.createExamWithAI()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            menu: UIMenu(title: "Tạo đề thi", children: [bankAction, aiAction])
        )
        navigationItem.rightBarButtonItem?.tintColor = BeeTheme.amber
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "clock.arrow.circlepath"),
            style: .plain, target: self, action: #selector(historyTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = BeeTheme.amber
    }

    private func setupLayout() {
        [tableView, emptyLabel, loadingIndicator].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Fetch
    private func fetchMyQuizzes() {
        loadingIndicator.startAnimating()
        QuizAPIService.shared.getMyQuizzes { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()
                switch result {
                case .success(let list):
                    self.quizzes = list
                    self.emptyLabel.isHidden = !list.isEmpty
                    self.tableView.reloadData()
                case .failure:
                    self.showAlert("Không thể tải danh sách đề thi")
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func createExamTapped() {
        let vc = CreateExamViewController()
        vc.onCreated = { [weak self] in self?.fetchMyQuizzes() }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func createExamWithAI() {
        let vc = AIGeneratorViewController(mode: .quiz)
        vc.onSaved = { [weak self] in self?.fetchMyQuizzes() }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func historyTapped() {
        navigationController?.pushViewController(ExamHistoryViewController(), animated: true)
    }

    private func showAlert(_ msg: String) {
        let a = UIAlertController(title: "Lỗi", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - DataSource
extension ExamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { quizzes.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExamTCell.reuseID, for: indexPath) as! ExamTCell
        cell.configure(with: quizzes[indexPath.row])
        cell.onTake = { [weak self] in
            guard let self = self else { return }
            let detailVC = ExamDetailViewController(quiz: self.quizzes[indexPath.row])
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            let quiz = self.quizzes[indexPath.row]
            let alert = UIAlertController(title: "Xoá đề thi", message: "Bạn chắc chắn muốn xoá \"\(quiz.title)\"?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
            alert.addAction(UIAlertAction(title: "Xoá", style: .destructive) { _ in
                QuizAPIService.shared.deleteQuiz(id: quiz.id) { success in
                    DispatchQueue.main.async {
                        if success { self.fetchMyQuizzes() }
                        else { self.showAlert("Xoá thất bại") }
                    }
                }
            })
            self.present(alert, animated: true)
        }
        return cell
    }
}
