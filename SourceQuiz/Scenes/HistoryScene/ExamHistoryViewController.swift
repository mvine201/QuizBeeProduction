//
//  HistoryViewController.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 18/4/26.
//

import UIKit

final class ExamHistoryViewController: UIViewController {

    private var history: [QuizResult] = []

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = BeeTheme.cream
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 18, right: 0)
        tv.register(ExamHistoryTCell.self, forCellReuseIdentifier: ExamHistoryTCell.reuseID)
        tv.dataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 110
        return tv
    }()

    private lazy var emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Chưa có lịch sử làm bài."
        l.textColor = BeeTheme.muted
        l.textAlignment = .center
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lịch sử"
        BeeTheme.applyAppBackground(view)
        setupLayout()
        fetchHistory()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchHistory()
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
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func fetchHistory() {
        loadingIndicator.startAnimating()
        QuizAPIService.shared.getHistory { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()
                switch result {
                case .success(let list):
                    self.history = list
                    self.emptyLabel.isHidden = !list.isEmpty
                    self.tableView.reloadData()
                case .failure:
                    self.emptyLabel.isHidden = false
                    self.emptyLabel.text = "Không thể tải lịch sử làm bài"
                }
            }
        }
    }
}

// MARK: - DataSource
extension ExamHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { history.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExamHistoryTCell.reuseID, for: indexPath) as! ExamHistoryTCell
        cell.configure(with: history[indexPath.row])
        return cell
    }
}

// MARK: - History Cell
final class ExamHistoryTCell: UITableViewCell {
    static let reuseID = "ExamHistoryTCell"

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyCard(v, radius: 12)
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = BeeTheme.ink
        l.numberOfLines = 2
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = BeeTheme.muted
        return l
    }()

    private let correctLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = BeeTheme.muted
        return l
    }()

    private let scoreBadge: UILabel = {
        let l = UILabel()
        l.font = .monospacedDigitSystemFont(ofSize: 24, weight: .black)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.backgroundColor = BeeTheme.paleHoney
        l.layer.cornerRadius = 16
        l.clipsToBounds = true
        l.widthAnchor.constraint(equalToConstant: 68).isActive = true
        l.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let infoStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, correctLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        let mainRow = UIStackView(arrangedSubviews: [infoStack, scoreBadge])
        mainRow.axis = .horizontal
        mainRow.alignment = .center
        mainRow.spacing = 8
        mainRow.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardView)
        cardView.addSubview(mainRow)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),

            mainRow.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            mainRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mainRow.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with result: QuizResult) {
        titleLabel.text = result.quiz?.title ?? "Đề thi"
        correctLabel.text = "Đúng \(result.correctCount)/\(result.totalQuestions) câu"

        let score = result.score
        scoreBadge.text = String(format: "%.1f", score)
        scoreBadge.textColor = score >= 8 ? BeeTheme.success : score >= 5 ? BeeTheme.amber : BeeTheme.danger

        if let dateStr = result.createdAt {
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: dateStr) {
                let display = DateFormatter()
                display.dateFormat = "dd/MM/yyyy HH:mm"
                dateLabel.text = display.string(from: date)
            }
        }
    }
}
