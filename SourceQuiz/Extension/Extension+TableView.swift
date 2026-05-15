//
//  Extension+TableView.swift
//  Quiz Bee
//
//  Created by Mạc Văn Vinh on 11/4/26.
//
import UIKit

protocol Reusable {
    static var identifier: String { get }
}

extension Reusable {
    static var identifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}


extension UITableView {
    
    // MARK: - Register Cell
    
    func registerCell<T: UITableViewCell>(_ cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: T.identifier)
    }
    
    func registerNibCell<T: UITableViewCell>(_ cellType: T.Type) {
        let nib = UINib(nibName: T.identifier, bundle: nil)
        register(nib, forCellReuseIdentifier: T.identifier)
    }
    
    // MARK: - Dequeue Cell
    
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: T.identifier,
            for: indexPath
        ) as? T else {
            fatalError("Cannot dequeue cell: \(T.identifier)")
        }
        return cell
    }
    
    // MARK: - Register Header/Footer
    
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(_ viewType: T.Type) {
        register(viewType, forHeaderFooterViewReuseIdentifier: T.identifier)
    }
    
    func registerNibHeaderFooter<T: UITableViewHeaderFooterView>(_ viewType: T.Type) {
        let nib = UINib(nibName: T.identifier, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: T.identifier)
    }
    
    // MARK: - Dequeue Header/Footer
    
    func dequeueHeaderFooter<T: UITableViewHeaderFooterView>() -> T {
        guard let view = dequeueReusableHeaderFooterView(
            withIdentifier: T.identifier
        ) as? T else {
            fatalError("Cannot dequeue header/footer: \(T.identifier)")
        }
        return view
    }
}

extension UIViewController {
    func enableKeyboardDismissOnTap(cancelsTouchesInView: Bool = false) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(sqDismissKeyboard))
        tap.cancelsTouchesInView = cancelsTouchesInView
        view.addGestureRecognizer(tap)
    }

    func configureKeyboardDismissal(for inputs: [UIView]) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Xong", style: .prominent, target: self, action: #selector(sqDismissKeyboard)),
        ]

        inputs.forEach { input in
            if let textField = input as? UITextField {
                textField.returnKeyType = .done
                textField.inputAccessoryView = toolbar
                textField.addTarget(self, action: #selector(sqTextFieldDidEndOnExit(_:)), for: .editingDidEndOnExit)
            } else if let textView = input as? UITextView {
                textView.inputAccessoryView = toolbar
            }
        }
    }

    @objc private func sqDismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func sqTextFieldDidEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}
