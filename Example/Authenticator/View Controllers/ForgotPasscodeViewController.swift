//
//  ForgotPasscodeViewController
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

final class ForgotPasscodeViewController: BaseViewController {
    private var noDataView: NoDataView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNoDataView()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupNoDataView() {
        let emptyData = EmptyViewData(
            image: UIImage(named: "forgotPasscode")!,
            title: "Forgot passcode?",
            description: "Please clear app data and establish new connection with your provider.",
            buttonTitle: l10n(.clearData)
        )
        noDataView = NoDataView(data: emptyData, action: clearDataPressed)
    }

    @objc private func clearDataPressed() {
        print("clear pressed")
    }
}

extension ForgotPasscodeViewController: Layoutable {
    func layout() {
        guard let noDataView = noDataView else { return }

        view.addSubview(noDataView)

        noDataView.topToSuperview(offset: AppLayout.screenHeight * 0.24)
        noDataView.widthToSuperview()
    }
}
