//
//  ConsentDetailViewController
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

private struct Layout {
    static let cornerRadius: CGFloat = 6.0
    static let sideOffset: CGFloat = 16.0
    static let expiresLabelTopOffset: CGFloat = 8.0
    static let titleLabelTopOffset: CGFloat = 16.0
    static let descriptionLabelTopOffset: CGFloat = 8.0
    static let stackViewTopOffset: CGFloat = 16.0
    static let sharedDataViewTopOffset: CGFloat = 10.0
    static let sharedDataViewHeight: CGFloat = AppLayout.screenHeight * 0.049
    static let expirationViewHeight: CGFloat = AppLayout.screenHeight * 0.049
    static let expirationViewBottomOffset: CGFloat = -16.0
}

final class ConsentDetailViewController: BaseViewController {
    private let scrollView = UIScrollView()
    private let expiresLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_16regular
        label.textColor = .dark60
        label.textAlignment = .left
        return label
    }()
    private let titleLabel = UILabel(font: .auth_20regular, alignment: .left)
    private let descriptionLabel = UILabel(font: .auth_14regular, alignment: .left)
    private let stackView = UIStackView(axis: .vertical, alignment: .fill, spacing: 1.0, distribution: .fillProportionally)
    private lazy var sharedDataView = ConsentSharedDataView()
    private let expirationView = ConsentExpirationView()

    var viewModel: ConsentDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRevokeButton()
        setupLabels()
        setupStackView()
        setupSharedData()
        setupExpirationView()
        layout()
    }

    @objc private func revokePressed() {
        viewModel.revokePressed()
    }
}

// MARK: - Setup
private extension ConsentDetailViewController {
    func setupRevokeButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: l10n(.revoke),
            style: .plain,
            target: self,
            action: #selector(revokePressed)
        )
    }

    func setupLabels() {
        navigationItem.title = viewModel.navigationTitle
        expiresLabel.text = viewModel.expiresInText
        titleLabel.text = viewModel.title
        descriptionLabel.attributedText = viewModel.descriptionAtributedString
    }

    func setupStackView() {
        viewModel.accountsViewDataArray.forEach {
            let accountView = ConsentAccountView()
            accountView.accountData = $0
            stackView.addArrangedSubview(accountView)
        }

        if stackView.arrangedSubviews.count == 1, let view = stackView.arrangedSubviews.first {
            view.roundTopCorners(radius: Layout.cornerRadius)
            view.roundBottomCorners(radius: Layout.cornerRadius)
        } else if stackView.arrangedSubviews.count > 1,
            let first = stackView.arrangedSubviews.first,
            let last = stackView.arrangedSubviews.last {
            first.roundTopCorners(radius: Layout.cornerRadius)
            last.roundBottomCorners(radius: Layout.cornerRadius)
        }
    }

    func setupSharedData() {
        if let sharedData = viewModel.consentSharedData {
            sharedDataView.data = sharedData
        }
    }

    func setupExpirationView() {
        expirationView.data = viewModel.expirationData
    }
}

// MARK: - Layout
extension ConsentDetailViewController: Layoutable {
    func layout() {
        view.addSubview(scrollView)

        scrollView.addSubviews(expiresLabel, titleLabel, descriptionLabel, stackView, expirationView)

        scrollView.edgesToSuperview()

        expiresLabel.top(to: scrollView, offset: Layout.expiresLabelTopOffset)
        expiresLabel.left(to: view, offset: Layout.sideOffset)
        expiresLabel.right(to: view, offset: -Layout.sideOffset)

        titleLabel.topToBottom(of: expiresLabel, offset: Layout.titleLabelTopOffset)
        titleLabel.left(to: view, offset: Layout.sideOffset)
        titleLabel.right(to: view, offset: -Layout.sideOffset)

        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionLabelTopOffset)
        descriptionLabel.left(to: view, offset: Layout.sideOffset)
        descriptionLabel.right(to: view, offset: -Layout.sideOffset)

        stackView.topToBottom(of: descriptionLabel, offset: Layout.stackViewTopOffset)
        stackView.left(to: view, offset: Layout.sideOffset)
        stackView.right(to: view, offset: -Layout.sideOffset)

        if viewModel.hasSharedData {
            scrollView.addSubview(sharedDataView)

            sharedDataView.topToBottom(of: stackView, offset: Layout.sharedDataViewTopOffset)
            sharedDataView.left(to: view, offset: Layout.sideOffset)
            sharedDataView.right(to: view, offset: -Layout.sideOffset)
            sharedDataView.height(Layout.sharedDataViewHeight)

            expirationView.topToBottom(of: sharedDataView, offset: Layout.sideOffset)
        } else {
            expirationView.topToBottom(of: scrollView, offset: Layout.sideOffset)
        }

        expirationView.leftToSuperview(offset: Layout.sideOffset)
        expirationView.height(Layout.expirationViewHeight)
        expirationView.bottom(to: scrollView, offset: Layout.expirationViewBottomOffset)
    }
}

// MARK: - Corners
private extension UIView {
    func roundTopCorners(radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    func roundBottomCorners(radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
