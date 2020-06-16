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

// TODO: REFACTOR
final class SingleAuthorizationViewController: BaseViewController {
    private let authorizationHeaderView = AuthorizationHeaderView()
    private let contentView = AuthorizationContentView()

    private var detailViewModel: AuthorizationDetailViewModel?
    private var authorizationData: SEAuthorizationData?
    private var connection: Connection?
    private var headerTimer: Timer?

    init(connectionId: String, authorizationId: String) {
        super.init(nibName: nil, bundle: .authenticator_main)

        guard let connection = ConnectionsCollector.with(id: connectionId) else { return }

        self.connection = connection

        AuthorizationsInteractor.refresh(
            connection: connection,
            authorizationId: authorizationId,
            success: { [weak self] encryptedAuthorization in
                guard let strongSelf = self else { return }

                DispatchQueue.global(qos: .background).async {
                    guard let decryptedAuthorizationData =
                        AuthorizationsPresenter.decryptedData(from: encryptedAuthorization) else { return }

                    strongSelf.authorizationData = decryptedAuthorizationData

                    DispatchQueue.main.async {
                        let detailViewModel = AuthorizationDetailViewModel(decryptedAuthorizationData)

                        strongSelf.detailViewModel = detailViewModel
                        strongSelf.authorizationHeaderView.viewModel = detailViewModel
                        strongSelf.contentView.viewModel = detailViewModel
                        strongSelf.setTimer()
                    }
                }
            },
            failure: { error in
                print(error)
            },
            connectionNotFoundFailure: { connectionId in
                if let id = connectionId, let connection = ConnectionsCollector.with(id: id) {
                    ConnectionRepository.setInactive(connection)
                }
            }
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationHeaderView.backgroundColor = .backgroundColor
        contentView.backgroundColor = .clear
        contentView.delegate = self
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SingleAuthorizationViewController: AuthorizationCellDelegate {
    func confirmPressed(_ authorizationId: String) {
        guard let detailViewModel = detailViewModel,
            let connection = connection,
            let url = connection.baseUrl else { return }

        let confirmData = SEConfirmAuthorizationRequestData(
            url: url,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: authorizationId,
            authorizationCode: detailViewModel.authorizationCode
        )

        detailViewModel.state.value = .processing

        AuthorizationsInteractor.confirm(
            data: confirmData,
            success: {
                detailViewModel.state.value = .success
                detailViewModel.actionTime = Date()
                after(3.0) {
                    self.close()
                }
            },
            failure: { _ in
                detailViewModel.state.value = .undefined
                detailViewModel.actionTime = Date()
                after(3.0) {
                    self.close()
                }
            }
        )
    }
    
    func denyPressed(_ authorizationId: String) {
        guard let detailViewModel = detailViewModel,
            let connection = connection,
            let url = connection.baseUrl else { return }
        
        let confirmData = SEConfirmAuthorizationRequestData(
            url: url,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: authorizationId,
            authorizationCode: detailViewModel.authorizationCode
        )

        detailViewModel.state.value = .processing

        AuthorizationsInteractor.deny(
            data: confirmData,
            success: {
                detailViewModel.state.value = .denied
                detailViewModel.actionTime = Date()
                after(3.0) {
                    self.close()
                }
            },
            failure: { _ in
                detailViewModel.state.value = .undefined
                detailViewModel.actionTime = Date()
                after(3.0) {
                    self.close()
                }
            }
        )
    }
}
