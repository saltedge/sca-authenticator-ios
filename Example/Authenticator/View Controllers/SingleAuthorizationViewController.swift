//
//  SingleAuthorizationViewController
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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
import SEAuthenticator

final class SingleAuthorizationViewController: BaseViewController {
    private let authorizationHeaderView = AuthorizationHeaderView()
    private let contentView = AuthorizationContentView()

    private var viewModel: SingleAuthorizationViewModel
    private var headerTimer: Timer?

    init(connectionId: String, authorizationId: String) {
        viewModel = SingleAuthorizationViewModel(connectionId: connectionId, authorizationId: authorizationId)
        super.init(nibName: nil, bundle: .authenticator_main)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationHeaderView.backgroundColor = .backgroundColor
        contentView.backgroundColor = .clear
        layout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }

    deinit {
        stopTimer()
    }

    func setTimer() {
        if headerTimer == nil {
            let timer = Timer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(updateTimer),
                userInfo: nil,
                repeats: true
            )
            RunLoop.current.add(timer, forMode: .common)

            self.headerTimer = timer
        }
    }

    func stopTimer() {
        headerTimer?.invalidate()
        headerTimer = nil
    }

    @objc func updateTimer() {
        authorizationHeaderView.updateTime()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layoutable
extension SingleAuthorizationViewController: Layoutable {
    func layout() {
        view.addSubviews(authorizationHeaderView, contentView)

        authorizationHeaderView.topToSuperview(offset: 30.0)
        authorizationHeaderView.leftToSuperview(offset: 32.0)
        authorizationHeaderView.rightToSuperview(offset: -32.0)
        authorizationHeaderView.height(48.0)

        contentView.topToBottom(of: authorizationHeaderView, offset: 30.0)
        contentView.widthToSuperview()
        contentView.bottomToSuperview()
    }
}

// MARK: - SingleAuthorizationViewModelEventsDelegate
extension SingleAuthorizationViewController: SingleAuthorizationViewModelEventsDelegate {
    func receivedDetailViewModel(_ detailViewModel: AuthorizationDetailViewModel) {
        authorizationHeaderView.viewModel = detailViewModel
        contentView.viewModel = detailViewModel
        setTimer()
    }

    func shouldClose() {
        close()
    }
}
