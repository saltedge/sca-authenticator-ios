//
//  SetupAppViewController.swift
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

protocol SetupAppDelegate: class {
    func receivedQrMetadata(data: String)
    func dismiss()
}

final class SetupAppViewController: BaseViewController {
    private let passcodeVc = PasscodeViewController(viewModel: PasscodeViewModel(purpose: .create))
    private lazy var qrCodeViewController = QRCodeViewController()
    private var connectViewCoordinator: ConnectViewCoordinator?

    weak var delegate: SetupAppDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        add(passcodeVc)

        passcodeVc.completeClosure = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.setupQrCodeViewController()
        }
    }

    private func setupQrCodeViewController() {
        qrCodeViewController.delegate = self
        qrCodeViewController.shouldDismissClosure = {
            self.delegate?.dismiss()
        }

        cycleFromViewController(
            oldViewController: passcodeVc,
            toViewController: qrCodeViewController
        )
    }
}

// MARK: - QRCodeViewControllerDelegate
extension SetupAppViewController: QRCodeViewControllerDelegate {
    func metadataReceived(data: String) {
        delegate?.receivedQrMetadata(data: data)
    }
}
