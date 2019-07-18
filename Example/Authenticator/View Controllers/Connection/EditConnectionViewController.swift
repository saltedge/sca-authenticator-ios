//
//  EditConnectionViewController.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2019 Salt Edge Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 or later.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//
//  For the additional permissions granted for Salt Edge Authenticator
//  under Section 7 of the GNU General Public License see THIRD_PARTY_NOTICES.md
//

import UIKit
import TinyConstraints

private struct Layout {
    static let fieldHeight: CGFloat = 48.0
    static let bankFieldTopOffset: CGFloat = 30.0
}

protocol EditConnectionViewControllerDelegate: class {
    func donePressed(text: String?)
}

final class EditConnectionViewController: BaseViewController {
    private let nameTextField: TextFieldWithOffset = {
        let textField = TextFieldWithOffset(15.0)
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Name"
        textField.backgroundColor = .white
        return textField
    }()
    private var connection: Connection

    weak var delegate: EditConnectionViewControllerDelegate?

    init(connection: Connection) {
        self.connection = connection
        super.init(nibName: nil, bundle: nil)
        nameTextField.text = connection.name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = l10n(.renameConnection)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: l10n(.done),
            style: .done,
            target: self,
            action: #selector(donePressed)
        )
        view.backgroundColor = .auth_backgroundColor
        nameTextField.setupBorders(for: .top, .bottom)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        layout()
        nameTextField.becomeFirstResponder()
    }

    @objc private func donePressed() {
        delegate?.donePressed(text: nameTextField.text)
    }

    @objc private func textFieldDidChange(_ textField: TextFieldWithOffset) {
        if let text = textField.text, !text.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

// MARK: - Layout
extension EditConnectionViewController: Layoutable {
    func layout() {
        view.addSubview(nameTextField)

        nameTextField.top(to: view, offset: Layout.bankFieldTopOffset)
        nameTextField.width(to: view)
        nameTextField.height(Layout.fieldHeight)
    }
}

private class TextFieldWithOffset: UITextField {
    init(_ sideOffset: CGFloat) {
        super.init(frame: .zero)
        let leftEmptyView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: sideOffset, height: height)))
        leftView = leftEmptyView
        leftViewMode = .always
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
