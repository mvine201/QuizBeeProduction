//
//  ProfileViewController.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 17/4/26.
//

import UIKit

final class ProfileViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let roleLabel = UILabel()
    private let usernameField = UITextField()
    private let emailField = UITextField()
    private let oldPasswordField = UITextField()
    private let newPasswordField = UITextField()
    private let confirmPasswordField = UITextField()
    private let saveProfileButton = UIButton(type: .system)
    private let changePasswordButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let messageLabel = UILabel()

    private var currentUser: AuthUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tài khoản"
        view.backgroundColor = BeeTheme.cream
        setupUI()
        fetchProfile()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchProfile()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 18

        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30),
        ])

        [usernameField, emailField, oldPasswordField, newPasswordField, confirmPasswordField].forEach {
            BeeTheme.styleField($0)
        }
        usernameField.placeholder = "Tên hiển thị"
        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        oldPasswordField.placeholder = "Mật khẩu hiện tại"
        newPasswordField.placeholder = "Mật khẩu mới"
        confirmPasswordField.placeholder = "Xác nhận mật khẩu mới"
        [oldPasswordField, newPasswordField, confirmPasswordField].forEach { $0.isSecureTextEntry = true }

        BeeTheme.primaryButton(saveProfileButton, title: "Lưu thông tin", icon: "checkmark.seal.fill")
        saveProfileButton.addTarget(self, action: #selector(saveProfileTapped), for: .touchUpInside)

        BeeTheme.primaryButton(changePasswordButton, title: "Cập nhật mật khẩu", icon: "lock.rotation")
        changePasswordButton.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)

        var logoutConfig = UIButton.Configuration.filled()
        logoutConfig.title = "Đăng xuất"
        logoutConfig.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        logoutConfig.imagePadding = 8
        logoutConfig.cornerStyle = .medium
        logoutConfig.baseBackgroundColor = BeeTheme.danger.withAlphaComponent(0.12)
        logoutConfig.baseForegroundColor = BeeTheme.danger
        logoutConfig.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 16, bottom: 13, trailing: 16)
        logoutButton.configuration = logoutConfig
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)

        messageLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        messageLabel.textColor = BeeTheme.muted
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true

        spinner.hidesWhenStopped = true

        stack.addArrangedSubview(makeHeaderCard())
        stack.addArrangedSubview(makeProfileCard())
        stack.addArrangedSubview(makePasswordCard())
        stack.addArrangedSubview(logoutButton)
        stack.addArrangedSubview(spinner)
        stack.addArrangedSubview(messageLabel)

        enableKeyboardDismissOnTap()
        configureKeyboardDismissal(for: [
            usernameField,
            emailField,
            oldPasswordField,
            newPasswordField,
            confirmPasswordField,
        ])
    }

    private func makeHeaderCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = BeeTheme.honey
        avatarView.layer.cornerRadius = 32
        avatarView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        avatarLabel.text = "🐝"
        avatarLabel.font = .systemFont(ofSize: 32)
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)
        NSLayoutConstraint.activate([
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
        ])

        nameLabel.text = "Quiz Bee"
        nameLabel.font = .systemFont(ofSize: 24, weight: .black)
        nameLabel.textColor = BeeTheme.ink
        nameLabel.numberOfLines = 2

        emailLabel.text = "Đang tải thông tin..."
        emailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emailLabel.textColor = BeeTheme.muted
        emailLabel.numberOfLines = 2

        roleLabel.text = "Thành viên chăm chỉ"
        roleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        roleLabel.textColor = BeeTheme.amber
        roleLabel.backgroundColor = BeeTheme.honey.withAlphaComponent(0.16)
        roleLabel.textAlignment = .center
        roleLabel.layer.cornerRadius = 9
        roleLabel.clipsToBounds = true
        roleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        roleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let textStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel, roleLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.alignment = .leading

        let row = UIStackView(arrangedSubviews: [avatarView, textStack])
        row.axis = .horizontal
        row.spacing = 16
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    private func makeProfileCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        let title = makeSectionTitle("Thông tin cá nhân", icon: "person.fill")
        let form = UIStackView(arrangedSubviews: [
            title,
            makeCaption("Tên hiển thị"),
            usernameField,
            makeCaption("Email"),
            emailField,
            saveProfileButton,
        ])
        form.axis = .vertical
        form.spacing = 11
        form.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(form)
        NSLayoutConstraint.activate([
            form.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            form.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            form.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            form.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    private func makePasswordCard() -> UIView {
        let card = UIView()
        BeeTheme.applyCard(card)

        let title = makeSectionTitle("Bảo mật", icon: "lock.fill")
        let form = UIStackView(arrangedSubviews: [
            title,
            makeCaption("Mật khẩu hiện tại"),
            oldPasswordField,
            makeCaption("Mật khẩu mới"),
            newPasswordField,
            makeCaption("Xác nhận mật khẩu mới"),
            confirmPasswordField,
            changePasswordButton,
        ])
        form.axis = .vertical
        form.spacing = 11
        form.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(form)
        NSLayoutConstraint.activate([
            form.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            form.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            form.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            form.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    private func fetchProfile() {
        setLoading(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                let user = try await APIClient.shared.getProfile()
                await MainActor.run {
                    self.currentUser = user
                    self.apply(user)
                    self.setLoading(false)
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.showMessage(error.localizedDescription, isError: true)
                }
            }
        }
    }

    private func apply(_ user: AuthUser) {
        nameLabel.text = user.username
        emailLabel.text = user.email ?? "Chưa có email"
        roleLabel.text = user.role == "admin" ? "Quản trị viên" : "Thành viên chăm chỉ"
        usernameField.text = user.username
        emailField.text = user.email
    }

    @objc private func saveProfileTapped() {
        let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !username.isEmpty else { return showMessage("Vui lòng nhập tên hiển thị.", isError: true) }
        guard !email.isEmpty else { return showMessage("Vui lòng nhập email.", isError: true) }

        setLoading(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                let user = try await APIClient.shared.updateProfile(username: username, email: email)
                await MainActor.run {
                    self.currentUser = user
                    self.apply(user)
                    self.setLoading(false)
                    self.showMessage("Đã lưu thông tin tài khoản.", isError: false)
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.showMessage(error.localizedDescription, isError: true)
                }
            }
        }
    }

    @objc private func changePasswordTapped() {
        let oldPassword = oldPasswordField.text ?? ""
        let newPassword = newPasswordField.text ?? ""
        let confirmPassword = confirmPasswordField.text ?? ""

        guard !oldPassword.isEmpty else { return showMessage("Vui lòng nhập mật khẩu hiện tại.", isError: true) }
        guard newPassword.count >= 6 else { return showMessage("Mật khẩu mới phải có ít nhất 6 ký tự.", isError: true) }
        guard newPassword == confirmPassword else { return showMessage("Mật khẩu xác nhận không khớp.", isError: true) }

        setLoading(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await APIClient.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                await MainActor.run {
                    self.oldPasswordField.text = ""
                    self.newPasswordField.text = ""
                    self.confirmPasswordField.text = ""
                    self.setLoading(false)
                    self.showMessage("Đã cập nhật mật khẩu.", isError: false)
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.showMessage(error.localizedDescription, isError: true)
                }
            }
        }
    }

    @objc private func handleLogout() {
        let alert = UIAlertController(
            title: "Đăng xuất",
            message: "Bạn muốn kết thúc phiên làm việc hiện tại?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Đăng xuất", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        APIClient.shared.clearAuthToken()

        let loginRoot = UINavigationController(rootViewController: LoginViewController())
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = loginRoot
            sceneDelegate.window?.makeKeyAndVisible()
        } else {
            present(loginRoot, animated: true)
        }
    }

    private func setLoading(_ isLoading: Bool) {
        [usernameField, emailField, oldPasswordField, newPasswordField, confirmPasswordField].forEach { $0.isEnabled = !isLoading }
        saveProfileButton.isEnabled = !isLoading
        changePasswordButton.isEnabled = !isLoading
        logoutButton.isEnabled = !isLoading
        isLoading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    private func showMessage(_ text: String, isError: Bool) {
        messageLabel.text = text
        messageLabel.textColor = isError ? BeeTheme.danger : BeeTheme.success
        messageLabel.isHidden = false
    }

    private func makeSectionTitle(_ text: String, icon: String) -> UIView {
        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = BeeTheme.amber
        imageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .black)
        label.textColor = BeeTheme.ink

        let row = UIStackView(arrangedSubviews: [imageView, label])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    private func makeCaption(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = BeeTheme.muted
        return label
    }
}
