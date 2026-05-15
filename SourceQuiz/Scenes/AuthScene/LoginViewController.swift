//
//  LoginViewController.swift
//  Quiz Bee
//
//  Created by Mạc Văn Vinh on 11/4/26.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - UI
    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "hexagon.fill"))
        iv.tintColor = BeeTheme.honey
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        tf.placeholder = "Mật khẩu"
        tf.isSecureTextEntry = true
        tf.textContentType = .password
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let forgotButton: UIButton = {
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
        BeeTheme.applyAppBackground(view)
        title = "Đăng nhập"
        setupUI()
        setupActions()
    }

    // MARK: - Setup
    private func setupUI() {
        BeeTheme.styleField(emailField)
        BeeTheme.styleField(passwordField)
        BeeTheme.primaryButton(loginButton, title: "Đăng nhập", icon: "arrow.right.circle.fill")
        BeeTheme.linkButton(forgotButton, title: "Quên mật khẩu?", icon: "key.fill")
        BeeTheme.linkButton(registerButton, title: "Chưa có tài khoản? Đăng ký", icon: "person.badge.plus")

        let brandLabel = BeeTheme.titleLabel("Quiz Bee", size: 30)
        brandLabel.textAlignment = .center

        let subtitleLabel = BeeTheme.bodyLabel("Học nhanh, luyện chắc, theo dõi kết quả trong một tổ ong gọn gàng.")
        subtitleLabel.textAlignment = .center

        let brandStack = UIStackView(arrangedSubviews: [brandLabel, subtitleLabel])
        brandStack.axis = .vertical
        brandStack.spacing = 6
        brandStack.translatesAutoresizingMaskIntoConstraints = false

        stack = UIStackView(arrangedSubviews: [emailField, passwordField, loginButton, forgotButton, registerButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(brandStack)
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

            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 36),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 76),
            logoImageView.widthAnchor.constraint(equalToConstant: 76),

            brandStack.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12),
            brandStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            brandStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            stack.topAnchor.constraint(equalTo: brandStack.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            emailField.heightAnchor.constraint(equalToConstant: 48),
            passwordField.heightAnchor.constraint(equalToConstant: 48),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            errorLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

            spinner.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])

        enableKeyboardDismissOnTap()
        configureKeyboardDismissal(for: [emailField, passwordField])
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        forgotButton.addTarget(self, action: #selector(handleForgot), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func handleLogin() {
        errorLabel.isHidden = true
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        guard !email.isEmpty, !password.isEmpty else {
            showError("Vui lòng nhập email và mật khẩu")
            return
        }
        setLoading(true)

        Task {
            do {
                _ = try await AuthAPI.shared.login(email: email, password: password)
                await MainActor.run {
                    self.setLoading(false)
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
                        default: self.showError("Đăng nhập thất bại. Vui lòng thử lại.")
                        }
                    } else {
                        self.showError("Lỗi kết nối. Vui lòng thử lại.")
                    }
                }
            }
        }
    }

    @objc private func handleRegister() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleForgot() {
        let vc = ForgotPasswordViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    // MARK: - Helpers
    private func setLoading(_ loading: Bool) {
        emailField.isEnabled = !loading
        passwordField.isEnabled = !loading
        loginButton.isEnabled = !loading
        forgotButton.isEnabled = !loading
        registerButton.isEnabled = !loading
        loading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
