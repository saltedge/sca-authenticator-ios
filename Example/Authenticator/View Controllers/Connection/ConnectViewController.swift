//
//  ConnectViewController.swift
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

// TODO: Review
enum ConnectionType: Equatable {
    case firstConnect(String)
    case connect
    case reconnect
    case deepLink

    static func == (lhs: ConnectionType, rhs: ConnectionType) -> Bool {
        switch (lhs, rhs) {
        case let (.firstConnect(url1), .firstConnect(url2)): return url1 == url2
        case (.connect, .connect), (.reconnect, .reconnect), (.deepLink, .deepLink): return true
        default: return false
        }
    }
}

final class ConnectViewController: BaseViewController {
    private lazy var loadingIndicator = LoadingIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCancelButton()
    }

    func startLoading() {
        view.addSubview(loadingIndicator)

        loadingIndicator.center(in: view)
        loadingIndicator.size(AppLayout.loadingIndicatorSize)

        loadingIndicator.start()
    }

    func stopLoading() {
        loadingIndicator.stop()
        loadingIndicator.removeFromSuperview()
    }
}

// MARK: - Setup
private extension ConnectViewController {
    func setupCancelButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: l10n(.cancel),
            style: .plain,
            target: self,
            action: #selector(close)
        )
    }
}

// MARK: - Actions
extension ConnectViewController {
    func showCompleteView(
        with state: CompleteView.State,
        title: String,
        description: String = l10n(.connectedSuccessfullyDescription),
        completion: (() -> ())? = nil
    ) {
        let completeView = CompleteView(state: state, title: title, description: description)
        completeView.proceedClosure = completion
        completeView.delegate = self
        completeView.alpha = 0.0

        view.addSubview(completeView)
        completeView.edges(to: view)
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.3) {
            completeView.alpha = 1.0
        }
    }
}

// MARK: - CompleteViewDelegate
extension ConnectViewController: CompleteViewDelegate {
    func proceedPressed(for view: CompleteView) {
        dismiss(animated: true, completion: nil)
    }
}
