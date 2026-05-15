//
//  HomeViewController.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 17/4/26.
//

import UIKit

final class HomeViewController: UIViewController {

    private var quizzes: [Quiz] = []
    private var currentPage = 1
    private var totalPages = 1
    private var keyword = ""
    private var isLoading = false

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Tìm kiếm đề thi công khai"
        controller.searchBar.delegate = self
        return controller
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = BeeTheme.cream
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 156
        table.register(PublicQuizCell.self, forCellReuseIdentifier: PublicQuizCell.reuseID)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Chưa có đề thi công khai phù hợp."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = BeeTheme.muted
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trang chủ"
        BeeTheme.applyAppBackground(view)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        setupLayout()
        fetchPublicQuizzes(reset: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchPublicQuizzes(reset: true)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func fetchPublicQuizzes(reset: Bool) {
        guard !isLoading else { return }
        if reset {
            currentPage = 1
            totalPages = 1
            quizzes.removeAll()
            tableView.reloadData()
        } else if currentPage >= totalPages {
            return
        } else {
            currentPage += 1
        }

        isLoading = true
        updateLoadingState()

        QuizAPIService.shared.getPublicQuizzes(keyword: keyword, page: currentPage, limit: 6) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                self.updateLoadingState()

                switch result {
                case .success(let response):
                    self.totalPages = max(response.totalPages, 1)
                    if reset {
                        self.quizzes = response.quizzes
                    } else {
                        self.quizzes.append(contentsOf: response.quizzes)
                    }
                    self.emptyLabel.isHidden = !self.quizzes.isEmpty
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    private func updateLoadingState() {
        if isLoading && quizzes.isEmpty {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }

        if isLoading && !quizzes.isEmpty {
            tableView.tableFooterView = makeLoadingFooter()
        } else {
            tableView.tableFooterView = UIView(frame: .zero)
        }
    }

    private func makeLoadingFooter() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 56))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = footer.center
        spinner.startAnimating()
        footer.addSubview(spinner)
        return footer
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Không thể tải đề thi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quizzes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PublicQuizCell.reuseID, for: indexPath) as! PublicQuizCell
        cell.configure(with: quizzes[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = keyword.isEmpty ? "Đề thi công khai mới nhất" : "Kết quả cho \"\(keyword)\""
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = BeeTheme.ink
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Chọn một đề thi công khai và bắt đầu luyện tập cùng Quiz Bee."
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = BeeTheme.muted
        subtitleLabel.numberOfLines = 0

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
        ])

        return container
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(PublicQuizDetailViewController(summaryQuiz: quizzes[indexPath.row]), animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = scrollView.contentSize.height - scrollView.bounds.height - 180
        if scrollView.contentOffset.y > threshold {
            fetchPublicQuizzes(reset: false)
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        keyword = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        //        fetchPublicQuizzes(reset: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyword.isEmpty {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: { [weak self] in
            if self?.keyword.isEmpty == true {
                return
            }
            self?.fetchPublicQuizzes(reset: true)
            
            //fetchPublicQuizzes(reset: true)
        })
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        keyword = ""
        fetchPublicQuizzes(reset: true)
    }
}

private final class PublicQuizCell: UITableViewCell {
    static let reuseID = "PublicQuizCell"

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyCard(view)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .black)
        label.textColor = BeeTheme.ink
        label.numberOfLines = 2
        return label
    }()

    private let authorLabel = PublicQuizCell.makeInfoLabel()
    private let timeLabel = PublicQuizCell.makeInfoLabel()
    private let attemptLabel = PublicQuizCell.makeInfoLabel()
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Công khai"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = BeeTheme.success
        label.backgroundColor = BeeTheme.success.withAlphaComponent(0.12)
        label.textAlignment = .center
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        let infoStack = UIStackView(arrangedSubviews: [timeLabel, authorLabel, attemptLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 8

        let topStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        topStack.axis = .horizontal
        topStack.spacing = 10
        topStack.alignment = .top

        let stack = UIStackView(arrangedSubviews: [topStack, infoStack])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardView)
        cardView.addSubview(stack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9),

            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 76),
            statusLabel.heightAnchor.constraint(equalToConstant: 26),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
        ])
    }

    func configure(with quiz: Quiz) {
        titleLabel.text = quiz.title
        setInfo(timeLabel, icon: "clock.fill", text: "Thời gian: \(quiz.timeLimit) phút")
        setInfo(authorLabel, icon: "person.fill", text: "Người tạo: \(quiz.author?.username ?? "Ẩn danh")")
        let attempts = quiz.attemptsAllowed > 0
            ? "Lượt làm: \(quiz.attemptsAllowed) lần"
            : "Lượt làm: Không giới hạn"
        setInfo(attemptLabel, icon: "arrow.clockwise", text: attempts)
    }

    private func setInfo(_ label: UILabel, icon: String, text: String) {
        let attachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        attachment.image = UIImage(systemName: icon, withConfiguration: configuration)?
            .withTintColor(BeeTheme.amber, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        let value = NSMutableAttributedString(attachment: attachment)
        value.append(NSAttributedString(string: "  \(text)"))
        label.attributedText = value
    }

    private static func makeInfoLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = BeeTheme.muted
        label.numberOfLines = 0
        return label
    }
}

private final class PublicQuizDetailViewController: UIViewController {

    private var quiz: Quiz
    private var reviews: [QuizReview] = []

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let spinner = UIActivityIndicatorView(style: .large)

    init(summaryQuiz: Quiz) {
        self.quiz = summaryQuiz
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Thông tin đề thi"
        BeeTheme.applyAppBackground(view)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "flag.fill"),
            style: .plain,
            target: self,
            action: #selector(reportQuiz)
        )
        navigationItem.rightBarButtonItem?.tintColor = BeeTheme.danger
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Báo cáo vi phạm"
        setupLayout()
        renderContent()
        fetchDetail()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16

        view.addSubview(scrollView)
        view.addSubview(spinner)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func fetchDetail() {
        spinner.startAnimating()
        let group = DispatchGroup()
        var loadedQuiz: Quiz?
        var loadedReviews: [QuizReview] = []
        var loadedError: Error?

        group.enter()
        QuizAPIService.shared.getQuizById(id: quiz.id) { result in
            if case .success(let quiz) = result { loadedQuiz = quiz }
            if case .failure(let error) = result { loadedError = error }
            group.leave()
        }

        group.enter()
        QuizAPIService.shared.getQuizReviews(quizId: quiz.id) { result in
            if case .success(let reviews) = result { loadedReviews = reviews }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.spinner.stopAnimating()
            if let loadedQuiz {
                self.quiz = loadedQuiz
                self.reviews = loadedReviews
                self.renderContent()
            } else if let loadedError {
                self.showError(loadedError.localizedDescription)
            }
        }
    }

    private func renderContent() {
        contentStack.arrangedSubviews.forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        contentStack.addArrangedSubview(makeDetailCard())
        contentStack.addArrangedSubview(makeReviewsCard())
    }

    private func makeDetailCard() -> UIView {
        let card = makeCard()

        let titleLabel = UILabel()
        titleLabel.text = quiz.title
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = BeeTheme.ink
        titleLabel.numberOfLines = 0

        let descriptionLabel = UILabel()
        descriptionLabel.text = quiz.description?.isEmpty == false ? quiz.description : "Đề thi công khai đã được duyệt trên hệ thống."
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = BeeTheme.muted
        descriptionLabel.numberOfLines = 0

        let infoStack = UIStackView(arrangedSubviews: [
            makeInfoRow(icon: "clock.fill", text: "Thời gian: \(quiz.timeLimit) phút"),
            makeInfoRow(icon: "doc.text.fill", text: "Số câu hỏi: \(quiz.questionCount) câu"),
            makeInfoRow(icon: "arrow.clockwise", text: quiz.attemptsAllowed > 0 ? "Lượt làm: \(quiz.attemptsAllowed) lần" : "Lượt làm: Không giới hạn"),
            makeInfoRow(icon: "person.fill", text: "Người tạo: \(quiz.author?.username ?? "Ẩn danh")"),
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 12

        let startButton = UIButton(type: .system)
        BeeTheme.primaryButton(startButton, title: "Bắt đầu làm bài", icon: "play.fill")
        startButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        startButton.addTarget(self, action: #selector(startExam), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, infoStack, startButton])
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])

        return card
    }

    private func makeReviewsCard() -> UIView {
        let card = makeCard()

        let titleLabel = UILabel()
        titleLabel.text = "Đánh giá từ người dùng"
        titleLabel.font = .systemFont(ofSize: 20, weight: .black)
        titleLabel.textColor = BeeTheme.ink

        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        if reviews.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Chưa có đánh giá nào. Bạn có thể để lại đánh giá sau khi làm bài."
            emptyLabel.font = .systemFont(ofSize: 14)
            emptyLabel.textColor = BeeTheme.muted
            emptyLabel.numberOfLines = 0
            stack.addArrangedSubview(emptyLabel)
        } else {
            reviews.forEach { stack.addArrangedSubview(makeReviewRow($0)) }
        }

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])

        return card
    }

    private func makeReviewRow(_ review: QuizReview) -> UIView {
        let nameLabel = UILabel()
        nameLabel.text = review.user?.username ?? "Ẩn danh"
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = BeeTheme.ink

        let ratingLabel = UILabel()
        ratingLabel.text = String(repeating: "★", count: max(1, min(review.rating, 5)))
        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        ratingLabel.textColor = BeeTheme.amber

        let commentLabel = UILabel()
        commentLabel.text = review.comment
        commentLabel.font = .systemFont(ofSize: 14)
        commentLabel.textColor = BeeTheme.muted
        commentLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [nameLabel, ratingLabel, commentLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private func makeInfoRow(icon: String, text: String) -> UIView {
        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = BeeTheme.amber
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.textColor = BeeTheme.ink
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [imageView, label])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        return row
    }

    private func makeCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)
        return card
    }

    @objc private func startExam() {
        let loadingAlert = UIAlertController(title: nil, message: "Đang tải đề thi...", preferredStyle: .alert)
        present(loadingAlert, animated: true)

        QuizAPIService.shared.getQuizForTake(id: quiz.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let quiz):
                        let takeVC = TakeExamViewController(quiz: quiz)
                        takeVC.modalPresentationStyle = .fullScreen
                        self.present(takeVC, animated: true)
                    case .failure(let error):
                        self.showError(error.localizedDescription)
                    }
                }
            }
        }
    }

    @objc private func reportQuiz() {
        present(QuizReportViewController(quizId: quiz.id), animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
