//
//  InfoView.swift
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
    static let buttonSideOffset: CGFloat = 20.0
    static let imageViewSize: CGSize = CGSize(width: 120.0, height: 120.0)
    static let secondaryButtonBottomOffset: CGFloat = 34.0
    static let mainButtonBottomOffset: CGFloat = 22.0
}

protocol InfoViewDelegate: class {
    func mainButtonPressed(_ view: InfoView)
    func secondaryButtonPressed(_ view: InfoView)
}

class InfoView: UIView {
    weak var delegate: InfoViewDelegate?

    private let imageView = UIImageView(frame: .zero)
    private var mainButton: CustomButton
    private let secondaryButton = CustomButton(.bordered, text: "")

    init(image: UIImage, mainButtonText: String, secondaryButtonText: String? = nil) {
        mainButton = CustomButton(.filled, text: mainButtonText)
        super.init(frame: .zero)
        imageView.image = image
        mainButton.addTarget(self, action: #selector(mainButtonPressed), for: .touchUpInside)
        if let secondaryButtonText = secondaryButtonText {
            secondaryButton.setTitle(secondaryButtonText, for: .normal)
            secondaryButton.addTarget(self, action: #selector(secondaryButtonPressed), for: .touchUpInside)
        } else {
            secondaryButton.isHidden = true
        }
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions
private extension InfoView {
    @objc func mainButtonPressed() {
        delegate?.mainButtonPressed(self)
    }

    @objc func secondaryButtonPressed() {
        delegate?.secondaryButtonPressed(self)
    }
}

// MARK: - Layout
extension InfoView: Layoutable {
    func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(imageView, mainButton, secondaryButton)
        imageView.centerX(to: self)
        imageView.size(Layout.imageViewSize)
        imageView.centerY(to: self, offset: -Layout.imageViewSize.height / 4 * 3)

        [mainButton, secondaryButton].forEach {
            $0.left(to: self, offset: Layout.buttonSideOffset)
            $0.right(to: self, offset: -Layout.buttonSideOffset)
        }

        secondaryButton.bottom(to: self, offset: -Layout.secondaryButtonBottomOffset)
        mainButton.bottomToTop(of: secondaryButton, offset: -Layout.mainButtonBottomOffset)
    }
}
