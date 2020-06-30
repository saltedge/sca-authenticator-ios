//
//  ConsentLogoView
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
    static let logoPlaceholderViewSize: CGSize = CGSize(width: 36.0, height: 36.0)
    static let connectionPlaceholderViewRadius: CGFloat = 6.0
    static let labelSideOffset: CGFloat = 10.0
}

struct ConsentLogoViewData {
    let imageUrl: URL?
    let title: String
    let description: String
}

final class ConsentLogoView: UIView {
    private let logoPlaceholderView: UIView = {
        let view = UIView()
        view.layer.masksToBounds =  true
        view.layer.cornerRadius = Layout.connectionPlaceholderViewRadius
        view.backgroundColor = .extraLightGray
        return view
    }()
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_17regular
        label.textColor = .titleColor
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_13regular
        label.textColor = .dark60
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    init() {
        super.init(frame: .zero)
        layout()
    }

    func set(data: ConsentLogoViewData) {
        titleLabel.text = data.title
        descriptionLabel.text = data.description

        if let imageUrl = data.imageUrl {
            CacheHelper.setAnimatedCachedImage(from: imageUrl, for: logoImageView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension ConsentLogoView: Layoutable {
    func layout() {
        addSubviews(logoPlaceholderView, titleLabel, descriptionLabel)
        logoPlaceholderView.addSubview(logoImageView)

        logoPlaceholderView.size(Layout.logoPlaceholderViewSize)
        logoPlaceholderView.topToSuperview()
        logoPlaceholderView.leftToSuperview()

        logoImageView.size(Layout.logoPlaceholderViewSize)
        logoImageView.centerInSuperview()

        titleLabel.topToSuperview()
        titleLabel.leftToRight(of: logoPlaceholderView, offset: Layout.labelSideOffset)

        descriptionLabel.topToBottom(of: titleLabel)
        descriptionLabel.leftToRight(of: logoPlaceholderView, offset: Layout.labelSideOffset)
    }
}
