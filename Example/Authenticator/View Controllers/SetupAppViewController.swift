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

private struct Layout {
    static let progressBarTopOffset: CGFloat = 52.0
    static let progressBarSideOffset: CGFloat = 30.0
    static let titleLabelTopOffset: CGFloat = 43.0
    static let labelsSideOffset: CGFloat = 30.0
    static let descriptionLabelTopOffset: CGFloat = 17.0
    static let infoViewsTopOffset: CGFloat = 15.0
    static let signUpCompleteViewTopOffset: CGFloat = 90.0
}

protocol SetupAppViewControllerDelegate: class {
    func allowBiometricsPressed()
    func allowNotificationsViewAction()
    func procceedPressed()
}

final class SetupAppViewController: BaseViewController {
    private let passcodeVc = PasscodeViewController(purpose: .create)
    private lazy var qrCodeViewController = QRCodeViewController()

    var receivedQrMetadata: ((String) -> ())?
    var dismissClosure: (() -> ())?

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
            self.dismissClosure?()
        }

        cycleFromViewController(
            oldViewController: passcodeVc,
            toViewController: UINavigationController(rootViewController: qrCodeViewController)
        )
    }
}

extension SetupAppViewController: QRCodeViewControllerDelegate {
    func metadataReceived(data: String) {
        dismiss(
            animated: true,
            completion: {
                self.receivedQrMetadata?(data)
            }
        )
    }
}
