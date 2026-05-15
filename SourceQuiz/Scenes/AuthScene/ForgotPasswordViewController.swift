import UIKit

final class ForgotPasswordViewController: UIViewController {

    private enum Step: Int { case email = 0, code, reset }

    private var current: Step = .email { didSet { updateStepUI() } }

    private let stepLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 22, weight: .black)
        lb.textColor = BeeTheme.ink
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nhập email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let sendCodeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let codeField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nhập mã OTP"
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let verifyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let newPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Mật khẩu mới (≥ 6 ký tự)"
        tf.isSecureTextEntry = true
        tf.textContentType = .newPassword
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let resetButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let messageLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = BeeTheme.muted
        lb.numberOfLines = 0
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let spinner: UIActivityIndicatorView = {
        let sp = UIActivityIndicatorView(style: .medium)
        sp.hidesWhenStopped = true
        sp.translatesAutoresizingMaskIntoConstraints = false
        return sp
    }()

    private var emailStack: UIStackView!
    private var codeStack: UIStackView!
    private var resetStack: UIStackView!
    private let scrollView = UIScrollView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quên mật khẩu"
        BeeTheme.applyAppBackground(view)
        setupUI()
        sendCodeButton.addTarget(self, action: #selector(handleSendCode), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(handleVerify), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        updateStepUI()
    }

    private func setupUI() {
        [emailField, codeField, newPasswordField].forEach {
            BeeTheme.styleField($0)
        }
        BeeTheme.primaryButton(sendCodeButton, title: "Gửi mã", icon: "paperplane.fill")
        BeeTheme.primaryButton(verifyButton, title: "Xác nhận mã", icon: "checkmark.seal.fill")
        BeeTheme.primaryButton(resetButton, title: "Đặt lại mật khẩu", icon: "key.fill")

        emailStack = UIStackView(arrangedSubviews: [emailField, sendCodeButton])
        emailStack.axis = .vertical
        emailStack.spacing = 12
        emailStack.translatesAutoresizingMaskIntoConstraints = false

        codeStack = UIStackView(arrangedSubviews: [codeField, verifyButton])
        codeStack.axis = .vertical
        codeStack.spacing = 12
        codeStack.translatesAutoresizingMaskIntoConstraints = false

        resetStack = UIStackView(arrangedSubviews: [newPasswordField, resetButton])
        resetStack.axis = .vertical
        resetStack.spacing = 12
        resetStack.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView(arrangedSubviews: [
            stepLabel,
            emailStack,
            codeStack,
            resetStack,
            messageLabel,
            spinner,
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            emailField.heightAnchor.constraint(equalToConstant: 48),
            codeField.heightAnchor.constraint(equalToConstant: 48),
            newPasswordField.heightAnchor.constraint(equalToConstant: 48),

            sendCodeButton.heightAnchor.constraint(equalToConstant: 50),
            verifyButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        enableKeyboardDismissOnTap()
        configureKeyboardDismissal(for: [emailField, codeField, newPasswordField])
    }

    private func updateStepUI() {
        switch current {
        case .email:
            stepLabel.text = "Bước 1/3: Nhập email để nhận mã"
            emailStack.isHidden = false
            codeStack.isHidden = true
            resetStack.isHidden = true
        case .code:
            stepLabel.text = "Bước 2/3: Nhập mã OTP"
            emailStack.isHidden = true
            codeStack.isHidden = false
            resetStack.isHidden = true
        case .reset:
            stepLabel.text = "Bước 3/3: Đặt mật khẩu mới"
            emailStack.isHidden = true
            codeStack.isHidden = true
            resetStack.isHidden = false
        }
        messageLabel.text = nil
    }

    private func setLoading(_ loading: Bool) {
        [emailField, sendCodeButton, codeField, verifyButton, newPasswordField, resetButton].forEach { $0.isUserInteractionEnabled = !loading }
        loading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    @objc private func handleSendCode() {
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !email.isEmpty else { messageLabel.text = "Vui lòng nhập email"; return }
        setLoading(true)
        Task {
            do {
                let resp = try await AuthAPI.shared.forgotPassword(email: email)
                await MainActor.run {
                    self.setLoading(false)
                    self.messageLabel.text = resp.message
                    self.current = .code
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.messageLabel.text = (error as? APIError).flatMap { if case let .server(msg) = $0 { return msg } else { return nil } } ?? "Không thể gửi mã. Vui lòng thử lại."
                }
            }
        }
    }

    @objc private func handleVerify() {
        let code = codeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else { messageLabel.text = "Vui lòng nhập mã"; return }
        setLoading(true)
        Task {
            do {
                let resp = try await AuthAPI.shared.verifyOTP(token: code)
                await MainActor.run {
                    self.setLoading(false)
                    self.messageLabel.text = resp.message
                    self.current = .reset
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.messageLabel.text = (error as? APIError).flatMap { if case let .server(msg) = $0 { return msg } else { return nil } } ?? "Mã không hợp lệ hoặc đã hết hạn"
                }
            }
        }
    }

    @objc private func handleReset() {
        let code = codeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newPass = newPasswordField.text ?? ""
        guard !code.isEmpty, newPass.count >= 6 else {
            messageLabel.text = "Vui lòng nhập mã và mật khẩu (≥ 6 ký tự)"
            return
        }
        setLoading(true)
        Task {
            do {
                let resp = try await AuthAPI.shared.resetPassword(token: code, newPassword: newPass)
                await MainActor.run {
                    self.setLoading(false)
                    self.messageLabel.text = resp.message
                    self.dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.messageLabel.text = (error as? APIError).flatMap { if case let .server(msg) = $0 { return msg } else { return nil } } ?? "Không thể đặt lại mật khẩu"
                }
            }
        }
    }
}
