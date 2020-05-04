//
//  NoDataView.swift
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
    static let imageViewSize: CGSize = CGSize(width: 104.0, height: 104.0)
    static let titleLabelTopOffset: CGFloat = 30.0
    static let descriptionLabelTopOffset: CGFloat = 10.0
    static let buttonSideOffset: CGFloat = 75.0
    static let buttonTopOffset: CGFloat = 28.0
}

class NoDataView: UIView {
    private let imageView = UIImageView(frame: .zero)
    private let titleLabel = UILabel(font: .systemFont(ofSize: 21.0))
    private let descriptionLabel = UILabel(font: .systemFont(ofSize: 17.0))
    private var onCTAPress: (() -> ())?
    private let containerView = UIView()

    init(image: UIImage, title: String, description: String, ctaTitle: String? = nil, onCTAPress: (() -> ())? = nil) {
        self.onCTAPress = onCTAPress
        super.init(frame: .zero)
        alpha = 0.0
//        imageView.image = image
        imageView.backgroundColor = .lightGray
        titleLabel.text = title
        descriptionLabel.text = description
        descriptionLabel.numberOfLines = 0
        layout()
        if let title = ctaTitle, onCTAPress != nil {
            setupButton(with: title)
        } else {
            descriptionLabel.bottom(to: self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton(with title: String) {
        let button = CustomButton(text: title)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        addSubview(button)

        button.topToBottom(of: descriptionLabel, offset: Layout.buttonTopOffset)
        button.centerX(to: self)
        button.widthToSuperview(offset: -128.0)
        button.bottom(to: self)
    }

    @objc private func buttonPressed() {
        onCTAPress?()
    }
}

// MARK: - Layout
extension NoDataView: Layoutable {
    func layout() {
        addSubviews(imageView, titleLabel, descriptionLabel)

        imageView.height(AppLayout.screenHeight * 0.246)
        imageView.width(to: self, offset: -32.0)
        imageView.top(to: self)
        imageView.centerX(to: self)

        titleLabel.widthToSuperview(offset: -64.0)
        titleLabel.topToBottom(of: imageView, offset: Layout.titleLabelTopOffset)
        titleLabel.centerX(to: self)

        descriptionLabel.widthToSuperview(offset: -54.0)
        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionLabelTopOffset)
        descriptionLabel.centerX(to: self)
    }
}
