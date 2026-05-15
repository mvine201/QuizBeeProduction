import UIKit

class QuestionBankViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var banks: [QuestionBank] = []
    private var addButton: UIBarButtonItem!
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Chưa có ngân hàng câu hỏi\nTạo từ file hoặc nhờ ong AI tổng hợp kiến thức."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = BeeTheme.muted
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kho câu hỏi"
        view.backgroundColor = BeeTheme.cream
        setupNavigation()
        setupCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBanks()
    }

    private func setupNavigation() {
        let fileAction = UIAction(title: "Tạo từ file", image: UIImage(systemName: "doc.badge.plus")) { [weak self] _ in
            self?.didTapAdd()
        }
        let aiAction = UIAction(title: "Tạo bằng AI", image: UIImage(systemName: "sparkles")) { [weak self] _ in
            self?.didTapAI()
        }
        addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            menu: UIMenu(title: "Tạo ngân hàng", children: [fileAction, aiAction])
        )
        addButton.tintColor = BeeTheme.amber
        navigationItem.rightBarButtonItem = addButton
    }

    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(132))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            return NSCollectionLayoutSection(group: group)
        }

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = BeeTheme.cream
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 18, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
        // Sử dụng extension của bạn
        collectionView.register(QuestionBankCell.self)

        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }
    
    private func fetchBanks() {
        Task { [weak self] in
            do {
                let items = try await APIClient.shared.getMyBanks()
                await MainActor.run {
                    self?.banks = items
                    self?.emptyLabel.isHidden = !items.isEmpty
                    self?.collectionView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func didTapAdd() {
        let vc = CreateQuestionBankViewController()
        vc.onBankCreated = { [weak self] newBank in
            guard let self = self else { return }
            self.banks.insert(newBank, at: 0)
            self.collectionView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func didTapAI() {
        let vc = AIGeneratorViewController(mode: .bank)
        vc.onSaved = { [weak self] in self?.fetchBanks() }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Không thể tải ngân hàng", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension QuestionBankViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: QuestionBankCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: banks[indexPath.item])
        return cell
    }
}
extension QuestionBankViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bank = banks[indexPath.item]  // QuestionBank, không phải Question
        let questionDetailVC = QuestionDetailViewController(bank: bank)
        questionDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(questionDetailVC, animated: true)
    }
}
