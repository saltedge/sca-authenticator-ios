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
    static let imageViewSize: CGSize = CGSize(width: 120.0, height: 120.0)
    static let smallImageViewSize: CGSize = CGSize(width: 80.0, height: 80.0)
    static let imageViewBottomOffset: CGFloat = 40.0
    static let smallImageViewBottomOffset: CGFloat = 30.0
    static let titleLabelHeight: CGFloat = 48.0
    static let sideOffset: CGFloat = AppLayout.sideOffset
    static let smallButtonSideOffset: CGFloat = 75.0
    static let descriptionLabelTopOffset: CGFloat = 17.0
    static let proceedButtonBottomOffset: CGFloat = 20.0
    static let completeButtonBottomOffset: CGFloat = -35.0
    static let descriptionLabelBottomOffset: CGFloat = 40.0
    static let reportAProblemTopOffset: CGFloat = 20.0
}

protocol CompleteViewDelegate: class {
    func proceedPressed(for view: CompleteView)
}

final class CompleteView: UIView {
    enum State {
        case processing
        case complete
        case success
        case fail

        var accessoryView: UIView {
            switch self {
            case .success, .complete: return AspectFitImageView(imageName: "success")
            case .fail: return AspectFitImageView(imageName: "smth_wrong")
            default: return LoadingIndicator()
            }
        }

        var mainActionTitle: String {
           switch self {
           case .success, .complete: return l10n(.done)
           case .fail: return "Retry"
           default: return ""
           }
        }
    }

    weak var delegate: CompleteViewDelegate?

    private let imageContainerView = UIView()
    private let accessoryView: UIView
    private let titleLabel = UILabel(font: .systemFont(ofSize: 21.0, weight: .regular), textColor: .titleColor)
    private let descriptionLabel = UILabel(font: .systemFont(ofSize: 17.0, weight: .regular), textColor: .titleColor)
    private let proceedButton: CustomButton
    private var state: State

    var proceedClosure: (() -> ())?

    init(state: State, title: String, description: String = "This may take some time") {
        self.state = state
        proceedButton = CustomButton(text: state.mainActionTitle)
        accessoryView = state.accessoryView
        super.init(frame: .zero)
        imageContainerView.backgroundColor = .secondaryBackground
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        descriptionLabel.text = description
        descriptionLabel.numberOfLines = 0
        proceedButton.addTarget(self, action: #selector(proceedPressed), for: .touchUpInside)
        layout()
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

        imageContainerView.addSubview(accessoryView)

        imageContainerView.topToSuperview(offset: 120.0)
        imageContainerView.size(CGSize(width: 75.0, height: 75.0))
        imageContainerView.centerXToSuperview()

        accessoryView.size(CGSize(width: 55.0, height: 55.0))
        accessoryView.centerInSuperview()

        titleLabel.topToBottom(of: imageContainerView, offset: 26.0)
        titleLabel.centerX(to: self)
        titleLabel.left(to: self, offset: 32.0)
        titleLabel.right(to: self, offset: -32.0)

        descriptionLabel.topToBottom(of: titleLabel, offset: 10.0)
        descriptionLabel.left(to: self, offset: 27.0)
        descriptionLabel.right(to: self, offset: -27.0)

        proceedButton.topToBottom(of: descriptionLabel, offset: 28.0)
        proceedButton.left(to: self, offset: 64.0)
        proceedButton.right(to: self, offset: -64.0)
    }
}
