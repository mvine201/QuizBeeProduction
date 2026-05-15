import UIKit

enum BeeTheme {
    static let honey = UIColor(red: 1.00, green: 0.72, blue: 0.12, alpha: 1.0)
    static let amber = UIColor(red: 0.94, green: 0.53, blue: 0.07, alpha: 1.0)
    static let ink = UIColor(red: 0.12, green: 0.10, blue: 0.07, alpha: 1.0)
    static let muted = UIColor(red: 0.44, green: 0.42, blue: 0.37, alpha: 1.0)
    static let subtleText = UIColor(red: 0.62, green: 0.58, blue: 0.49, alpha: 1.0)
    static let cream = UIColor(red: 1.00, green: 0.98, blue: 0.91, alpha: 1.0)
    static let softHoney = UIColor(red: 1.00, green: 0.95, blue: 0.76, alpha: 1.0)
    static let paleHoney = UIColor(red: 1.00, green: 0.98, blue: 0.88, alpha: 1.0)
    static let border = UIColor(red: 0.90, green: 0.84, blue: 0.67, alpha: 1.0)
    static let card = UIColor.white
    static let success = UIColor(red: 0.18, green: 0.62, blue: 0.36, alpha: 1.0)
    static let danger = UIColor(red: 0.78, green: 0.18, blue: 0.18, alpha: 1.0)

    static func applyAppBackground(_ view: UIView) {
        view.backgroundColor = cream
    }

    static func applyCard(_ view: UIView, radius: CGFloat = 16) {
        view.backgroundColor = card
        view.layer.cornerRadius = radius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 14
    }

    static func applyOutlinedSurface(_ view: UIView, radius: CGFloat = 12) {
        view.backgroundColor = card
        view.layer.cornerRadius = radius
        view.layer.borderWidth = 1
        view.layer.borderColor = border.cgColor
    }

    static func applyNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = card
        appearance.shadowColor = border.withAlphaComponent(0.5)
        appearance.titleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 32, weight: .black),
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = amber
    }

    static func primaryButton(_ button: UIButton, title: String, icon: String? = nil) {
        configureButton(button, title: title, icon: icon, background: honey, foreground: ink)
    }

    static func secondaryButton(_ button: UIButton, title: String, icon: String? = nil) {
        configureButton(button, title: title, icon: icon, background: softHoney, foreground: ink)
    }

    static func destructiveButton(_ button: UIButton, title: String, icon: String? = nil) {
        configureButton(button, title: title, icon: icon, background: danger, foreground: .white)
    }

    static func successButton(_ button: UIButton, title: String, icon: String? = nil) {
        configureButton(button, title: title, icon: icon, background: success, foreground: .white)
    }

    static func linkButton(_ button: UIButton, title: String, icon: String? = nil) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = icon.flatMap { UIImage(systemName: $0) }
        config.imagePadding = 6
        config.baseForegroundColor = amber
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        button.configuration = config
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    }

    static func styleField(_ field: UITextField) {
        field.borderStyle = .none
        field.backgroundColor = card
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = border.cgColor
        field.textColor = ink
        field.font = .systemFont(ofSize: 15)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        field.leftViewMode = .always
        field.heightAnchor.constraint(greaterThanOrEqualToConstant: 46).isActive = true
    }

    static func styleTextView(_ textView: UITextView, minHeight: CGFloat = 92) {
        textView.backgroundColor = card
        textView.textColor = ink
        textView.font = .systemFont(ofSize: 15)
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = border.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
    }

    static func styleSegment(_ segment: UISegmentedControl) {
        segment.selectedSegmentTintColor = honey
        segment.setTitleTextAttributes([
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
        ], for: .selected)
        segment.setTitleTextAttributes([
            .foregroundColor: muted,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
        ], for: .normal)
    }

    static func titleLabel(_ text: String, size: CGFloat = 24) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: size, weight: .black)
        label.textColor = ink
        label.numberOfLines = 0
        return label
    }

    static func bodyLabel(_ text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = muted
        label.numberOfLines = 0
        return label
    }

    static func badge(text: String, textColor: UIColor = ink, background: UIColor = softHoney) -> UILabel {
        let label = UILabel()
        label.text = "  \(text)  "
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = textColor
        label.backgroundColor = background
        label.textAlignment = .center
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        return label
    }

    static func capsuleLabel(text: String, icon: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = icon.map { "\($0) \(text)" } ?? text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = muted
        label.backgroundColor = paleHoney
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }

    private static func configureButton(
        _ button: UIButton,
        title: String,
        icon: String?,
        background: UIColor,
        foreground: UIColor
    ) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = icon.flatMap { UIImage(systemName: $0) }
        config.imagePadding = 8
        config.cornerStyle = .medium
        config.baseBackgroundColor = background
        config.baseForegroundColor = foreground
        config.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 16, bottom: 13, trailing: 16)
        button.configuration = config
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
    }
}
