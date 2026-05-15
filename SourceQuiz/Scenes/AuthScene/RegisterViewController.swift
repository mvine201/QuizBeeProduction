//
//  RegisterViewController.swift
//  Quiz Bee
//
//  Created by Mạc Văn Vinh on 11/4/26.
//

import UIKit

final class RegisterViewController: UIViewController {

    // MARK: - UI
    private let usernameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Tên người dùng"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Mật khẩu (≥ 6 ký tự)"
        tf.isSecureTextEntry = true
        tf.textContentType = .newPassword
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let errorLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = BeeTheme.danger
        lb.numberOfLines = 0
        lb.font = .systemFont(ofSize: 14, weight: .semibold)
        lb.isHidden = true
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let spinner: UIActivityIndicatorView = {
        let sp = UIActivityIndicatorView(style: .medium)
        sp.hidesWhenStopped = true
        sp.translatesAutoresizingMaskIntoConstraints = false
        return sp
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var stack: UIStackView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Đăng ký"
        BeeTheme.applyAppBackground(view)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Đăng nhập", style: .plain, target: self, action: #selector(goToLogin))
        setupUI()
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }

    private func setupUI() {
        [usernameField, emailField, passwordField].forEach {
            BeeTheme.styleField($0)
        }
        BeeTheme.primaryButton(registerButton, title: "Tạo tài khoản", icon: "person.badge.plus.fill")

        let heroLabel = BeeTheme.titleLabel("Gia nhập Quiz Bee", size: 26)
        let subtitleLabel = BeeTheme.bodyLabel("Tạo tài khoản để lưu đề thi, ngân hàng câu hỏi và lịch sử luyện tập.")

        stack = UIStackView(arrangedSubviews: [usernameField, emailField, passwordField, registerButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(heroLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(stack)
        contentView.addSubview(errorLabel)
        contentView.addSubview(spinner)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            heroLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            heroLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            heroLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: heroLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: heroLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: heroLabel.trailingAnchor),

            stack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            usernameField.heightAnchor.constraint(equalToConstant: 48),
            emailField.heightAnchor.constraint(equalToConstant: 48),
            passwordField.heightAnchor.constraint(equalToConstant: 48),
            registerButton.heightAnchor.constraint(equalToConstant: 50),

            errorLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

            spinner.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])

        enableKeyboardDismissOnTap()
        configureKeyboardDismissal(for: [usernameField, emailField, passwordField])
    }

    // MARK: - Actions
    @objc private func handleRegister() {
        errorLabel.isHidden = true
        let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            showError("Vui lòng nhập đầy đủ thông tin")
            return
        }
        guard password.count >= 6 else {
            showError("Mật khẩu phải từ 6 ký tự")
            return
        }

        setLoading(true)
        Task {
            do {
                _ = try await AuthAPI.shared.register(username: username, email: email, password: password)
                _ = try await AuthAPI.shared.login(email: email, password: password)
                await MainActor.run {
                    self.setLoading(false)
                    // Sau khi đăng ký + đăng nhập, chuyển sang tab chính
                    let tab = MainTabBarController()
                    tab.modalPresentationStyle = .fullScreen
                    self.present(tab, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    if let apiErr = error as? APIError {
                        switch apiErr {
                        case .server(let msg): self.showError(msg)
                        case .unauthorized: self.showError("Không được phép")
                        case .forbidden: self.showError("Tài khoản bị khóa hoặc không có quyền")
                        default: self.showError("Đăng ký thất bại. Vui lòng thử lại.")
                        }
                    } else {
                        self.showError("Lỗi kết nối. Vui lòng thử lại.")
                    }
                }
            }
        }
    }

    @objc private func goToLogin() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers
    private func setLoading(_ loading: Bool) {
        usernameField.isEnabled = !loading
        emailField.isEnabled = !loading
        passwordField.isEnabled = !loading
        registerButton.isEnabled = !loading
        loading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
