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

private struct Layout {
    static let headerTopOffset: CGFloat = 16.0
    static let headerSideOffset: CGFloat = 32.0
    static let headerHeight: CGFloat = 48.0
    static let contentTopOffset: CGFloat = 10.0
}

final class SingleAuthorizationViewController: BaseViewController {
    private let authorizationHeaderView = AuthorizationHeaderView()
    private let contentView = AuthorizationContentView()

    private var viewModel: SingleAuthorizationViewModel
    private var headerTimer: Timer?

    var timerExpiredClosure: (() -> ())?

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

        authorizationHeaderView.topToSuperview(offset: Layout.headerTopOffset)
        authorizationHeaderView.leftToSuperview(offset: Layout.headerSideOffset)
        authorizationHeaderView.rightToSuperview(offset: -Layout.headerSideOffset)
        authorizationHeaderView.height(Layout.headerHeight)

        contentView.topToBottom(of: authorizationHeaderView, offset: Layout.contentTopOffset)
        contentView.widthToSuperview()
        contentView.bottom(to: view, view.safeAreaLayoutGuide.bottomAnchor)
    }
}

// MARK: - SingleAuthorizationViewModelEventsDelegate
extension SingleAuthorizationViewController: SingleAuthorizationViewModelEventsDelegate {
    func receivedDetailViewModel(_ detailViewModel: AuthorizationDetailViewModel) {
        setTimer()
        authorizationHeaderView.viewModel = detailViewModel
        contentView.viewModel = detailViewModel
    }

    func shouldClose() {
        close()
    }
}
