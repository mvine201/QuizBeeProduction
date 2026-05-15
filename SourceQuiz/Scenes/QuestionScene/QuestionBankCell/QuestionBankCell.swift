import UIKit
final class QuestionBankCell: UICollectionViewCell {

    private let container = UIView()
    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.backgroundColor = .clear

        container.translatesAutoresizingMaskIntoConstraints = false
        BeeTheme.applyCard(container)
        container.layer.cornerRadius = 16

        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = BeeTheme.paleHoney
        iconContainer.layer.cornerRadius = 22

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "books.vertical.fill")
        iconView.tintColor = BeeTheme.amber
        iconView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .black)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = BeeTheme.ink
        titleLabel.textAlignment = .left

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = BeeTheme.muted
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 2

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.addSubview(iconView)
        stack.addArrangedSubview(iconContainer)
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 7
        stack.addArrangedSubview(textStack)

        contentView.addSubview(container)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18),

            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            iconView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with bank: QuestionBank) {
        titleLabel.text = bank.title

        if let count = bank.questions?.count {
            subtitleLabel.text = "\(count) câu hỏi"
        } else if let desc = bank.description, !desc.isEmpty {
            subtitleLabel.text = desc
        } else {
            subtitleLabel.text = "Chưa có mô tả"
        }
    }
}
