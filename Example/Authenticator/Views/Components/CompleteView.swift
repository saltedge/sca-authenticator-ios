//
//  CompleteView.swift
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
    static let imageContainerTopOffset: CGFloat = AppLayout.screenHeight * 0.14
    static let imageContainerViewSize: CGSize = CGSize(width: 75.0, height: 75.0)
    static let accessoryViewSize: CGSize = CGSize(width: 55.0, height: 55.0)
    static let titleTopOffset: CGFloat = 26.0
    static let titleWidthOffset: CGFloat = -64.0
    static let descriptionTopOffset: CGFloat = 10.0
    static let descriptionWidthOffset: CGFloat = -54.0
    static let buttonTopOffset: CGFloat = 28.0
    static let buttonWidthOffset: CGFloat = -128.0
}

protocol CompleteViewDelegate: class {
    func proceedPressed(for view: CompleteView)
}

final class CompleteView: UIView {
    enum State {
        case processing
        case success
        case fail

        var accessoryView: UIView {
            switch self {
            case .success: return AspectFitImageView(imageName: "success")
            case .fail: return AspectFitImageView(imageName: "smth_wrong")
            default: return LoadingIndicatorView()
            }
        }

        var mainActionTitle: String {
           switch self {
           case .success: return l10n(.done)
           case .fail: return l10n(.retry)
           default: return ""
           }
        }
    }

    weak var delegate: CompleteViewDelegate?

    private let imageContainerView = RoundedShadowView(cornerRadius: 16.0)
    private var accessoryView: UIView?
    private let titleLabel = UILabel(font: .systemFont(ofSize: 21.0, weight: .regular), textColor: .titleColor)
    private let descriptionLabel = UILabel(font: .systemFont(ofSize: 17.0, weight: .regular), textColor: .titleColor)
    private let proceedButton: CustomButton
    private var state: State

    var proceedClosure: (() -> ())?

    init(state: State, title: String, description: String = l10n(.processingDescription)) {
        self.state = state
        proceedButton = CustomButton(text: state.mainActionTitle)
        super.init(frame: .zero)
        set(state: state, title: title, description: description)
        backgroundColor = .backgroundColor
        proceedButton.addTarget(self, action: #selector(proceedPressed), for: .touchUpInside)
        layout()
    }

    func set(state: State, title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description

        accessoryView?.removeFromSuperview()
        accessoryView = state.accessoryView
        if let accessoryView = accessoryView {
            imageContainerView.addSubview(accessoryView)
            accessoryView.size(Layout.accessoryViewSize)
            accessoryView.centerInSuperview()
        }

        if state == .processing, let loadingIndicator = accessoryView as? LoadingIndicatorView {
            proceedButton.isHidden = true
            loadingIndicator.start()
        } else {
            proceedButton.updateTitle(text: state.mainActionTitle)
            proceedButton.isHidden = false
        }
    }

    @objc private func proceedPressed() {
        proceedClosure?()
        delegate?.proceedPressed(for: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension CompleteView: Layoutable {
    func layout() {
        addSubviews(imageContainerView, titleLabel, descriptionLabel, proceedButton)

        imageContainerView.topToSuperview(offset: Layout.imageContainerTopOffset)
        imageContainerView.size(Layout.imageContainerViewSize)
        imageContainerView.centerXToSuperview()

        titleLabel.topToBottom(of: imageContainerView, offset: Layout.titleTopOffset)
        titleLabel.centerX(to: self)
        titleLabel.widthToSuperview(offset: Layout.titleWidthOffset)

        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionTopOffset)
        descriptionLabel.centerX(to: self)
        descriptionLabel.widthToSuperview(offset: Layout.descriptionWidthOffset)

        proceedButton.topToBottom(of: descriptionLabel, offset: Layout.buttonTopOffset)
        proceedButton.centerX(to: self)
        proceedButton.widthToSuperview(offset: Layout.buttonWidthOffset)
    }
}
