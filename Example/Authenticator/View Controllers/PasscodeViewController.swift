//
//  PasscodeViewController.swift
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
    static let passcodeViewTopOffset: CGFloat = 90.0
}

protocol PasscodeViewControllerDelegate: class {
    func completed()
    func wrongPasswordEntered()
    func biometricsPressed()
    func closePressed()
}

final class PasscodeViewController: BaseViewController {
    private var passcodeView: PasscodeView
    private var purpose: PasscodeView.Purpose

    private var viewModel: PasscodeViewModel

    weak var delegate: PasscodeViewControllerDelegate?

    init(purpose: PasscodeView.Purpose) {
        self.purpose = purpose
        viewModel = PasscodeViewModel(purpose: purpose)
        passcodeView = PasscodeView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        passcodeView.delegate = self
        if purpose == .edit { setupLeftButton() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = l10n(.passcode)
        layout()
    }
}

// MARK: - Setup
private extension PasscodeViewController {
    func setupLeftButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: l10n(.cancel),
            style: .plain,
            target: self,
            action: #selector(close)
        )
    }
}

// MARK: - Actions
extension PasscodeViewController {
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Layout
extension PasscodeViewController: Layoutable {
    func layout() {
        view.addSubview(passcodeView)
        passcodeView.edges(to: view, insets: UIEdgeInsets(top: Layout.passcodeViewTopOffset, left: 0.0, bottom: 0.0, right: 0.0))
    }
}

// MARK: - PasscodeViewDelegate
extension PasscodeViewController: PasscodeViewDelegate {
    func completed() {
        delegate?.completed()
        close()
    }

    func passwordCorrect() {
        if purpose == .enter {
            delegate?.completed()
            close()
        } else {
//            passcodeView.switchToCreate()
        }

    }

    func biometricsPressed() {
        delegate?.biometricsPressed()
    }

    func wrongPasscode() {
        delegate?.wrongPasswordEntered()
    }
}
