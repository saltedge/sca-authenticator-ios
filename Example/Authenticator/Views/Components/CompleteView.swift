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
        case complete
        case success
        case fail

        fileprivate var mainActionTitle: String {
            switch self {
            case .success, .complete: return l10n(.proceed)
            case .fail: return l10n(.ok)
            }
        }

        fileprivate var image: UIImage {
            switch self {
            case .success, .complete: return #imageLiteral(resourceName: "Success")
            case .fail: return #imageLiteral(resourceName: "Error")
            }
        }

        fileprivate var imageViewBottomOffset: CGFloat {
            switch self {
            case .complete: return Layout.imageViewBottomOffset
            case .success, .fail: return Layout.smallImageViewBottomOffset
            }
        }

        fileprivate var imageSize: CGSize {
            switch self {
            case .complete: return Layout.imageViewSize
            case .success, .fail: return Layout.smallImageViewSize
            }
        }

        fileprivate var buttonsOffset: CGFloat {
            switch self {
            case .complete: return Layout.sideOffset
            case .success, .fail: return Layout.smallButtonSideOffset
            }
        }
    }

    weak var delegate: CompleteViewDelegate?

    private let imageView: UIImageView
    private let titleLabel = UILabel.titleLabel
    private let descriptionLabel = UILabel.descriptionLabel
    private let proceedButton: CustomButton
    private var state: State

    var proceedClosure: (() -> ())?

    init(state: State, title: String, description: String = l10n(.connectedSuccessfullyDescription)) {
        self.state = state
        proceedButton = CustomButton(text: state.mainActionTitle)
        imageView = UIImageView(image: state.image)
        super.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        titleLabel.text = title
        descriptionLabel.text = description
        descriptionLabel.textColor = .auth_gray
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
        addSubviews(imageView, titleLabel, descriptionLabel, proceedButton)

        imageView.bottomToTop(of: titleLabel, offset: -state.imageViewBottomOffset)
        imageView.size(state.imageSize)
        imageView.centerX(to: self)

        titleLabel.bottomToTop(of: descriptionLabel, offset: -Layout.descriptionLabelTopOffset)
        titleLabel.centerX(to: self)
        titleLabel.left(to: self, offset: Layout.sideOffset)
        titleLabel.right(to: self, offset: -Layout.sideOffset)

        descriptionLabel.centerY(to: self)
        descriptionLabel.left(to: self, offset: Layout.sideOffset)
        descriptionLabel.right(to: self, offset: -Layout.sideOffset)

        proceedButton.left(to: self, offset: state.buttonsOffset)
        proceedButton.right(to: self, offset: -state.buttonsOffset)
        if state == .complete {
            proceedButton.bottom(to: self, offset: Layout.completeButtonBottomOffset)
        } else {
            proceedButton.topToBottom(of: descriptionLabel, offset: Layout.descriptionLabelBottomOffset)
        }
    }
}
