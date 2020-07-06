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
import SEAuthenticator

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

    var consent: SEConsentData

    override func viewDidLoad() {
        super.viewDidLoad()
        expiresLabel.text = "\(consent.expiresAt.get(.day)) days left"
        titleLabel.text = "Consent for account information access"
        setupDescription()
        setupStackView()
        setupSharedData()
        setupExpirationView()
        layout()
    }

    init(title: String, consent: SEConsentData) {
        self.consent = consent
        super.init(nibName: nil, bundle: .authenticator_main)
        navigationItem.title = title
    }

    private func setupDescription() {
        let attributedDescription = NSMutableAttributedString(string: l10n(.consentGrantedTo))

        let fontAttribute = [
            NSAttributedString.Key.font: UIFont.auth_14semibold
        ]

        guard let consentLocation = attributedDescription.string.range(of: "%{consent}") else { return }

        let consentRange = NSRange(consentLocation, in: attributedDescription.string)

        let tppAttributedName = NSMutableAttributedString(
            string: consent.tppName.capitalized,
            attributes: fontAttribute
        )
        attributedDescription.replaceCharacters(in: consentRange, with: tppAttributedName)

        guard let connectionLocation = attributedDescription.string.range(of: "%{connection}") else { return }

        let connectionRange = NSRange(connectionLocation, in: attributedDescription.string)

        let connectionAttributedName = NSMutableAttributedString(
            string: "Spring bank",
            attributes: fontAttribute
        )

        attributedDescription.replaceCharacters(in: connectionRange, with: connectionAttributedName)

        descriptionLabel.attributedText = attributedDescription
    }

    private func setupStackView() {
        consent.accounts.forEach {
            let accountView = ConsentAccountView()
            accountView.accountData = ConsentAccountViewData(
                name: $0.name,
                accountNumber: $0.accountNumber,
                sortCode: $0.sortCode,
                iban: $0.iban
            )
            stackView.addArrangedSubview(accountView)
        }

        if stackView.arrangedSubviews.count == 1, let view = stackView.arrangedSubviews.first {
            view.roundTopCorners(radius: 6.0)
            view.roundBottomCorners(radius: 6.0)
        } else if stackView.arrangedSubviews.count > 1,
            let first = stackView.arrangedSubviews.first,
            let last = stackView.arrangedSubviews.last {
            first.roundTopCorners(radius: 6.0)
            last.roundBottomCorners(radius: 6.0)
        }
    }

    private func setupSharedData() {
        if let sharedData = consent.sharedData {
            sharedDataView.data = sharedData
        }
    }

    private func setupExpirationView() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.timeZone = .utc

        let data = ConsentExpirationData(
            granted: formatter.string(from: consent.createdAt),
            expires: formatter.string(from: consent.expiresAt)
        )
        expirationView.data = data
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension ConsentDetailViewController: Layoutable {
    func layout() {
        view.addSubview(scrollView)

        scrollView.addSubviews(expiresLabel, titleLabel, descriptionLabel, stackView, expirationView)

        scrollView.edgesToSuperview()

        expiresLabel.top(to: scrollView, offset: 8.0)
        expiresLabel.left(to: view, offset: 16.0)
        expiresLabel.right(to: view, offset: -16.0)

        titleLabel.topToBottom(of: expiresLabel, offset: 16.0)
        titleLabel.left(to: view, offset: 16.0)
        titleLabel.right(to: view, offset: -16.0)

        descriptionLabel.topToBottom(of: titleLabel, offset: 8.0)
        descriptionLabel.left(to: view, offset: 16.0)
        descriptionLabel.right(to: view, offset: -16.0)

        stackView.topToBottom(of: descriptionLabel, offset: 16.0)
        stackView.left(to: view, offset: 16.0)
        stackView.right(to: view, offset: -16.0)

        if consent.sharedData != nil {
            scrollView.addSubview(sharedDataView)

            sharedDataView.topToBottom(of: stackView, offset:  10.0)
            sharedDataView.left(to: view, offset: 16.0)
            sharedDataView.right(to: view, offset: -16.0)
            sharedDataView.height(40.0)

            expirationView.topToBottom(of: sharedDataView, offset: 16.0)
        } else {
            expirationView.topToBottom(of: scrollView, offset: 16.0)
        }

        expirationView.leftToSuperview(offset: 16.0)
        expirationView.height(40.0)
        expirationView.bottom(to: scrollView, offset: -16.0)
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
