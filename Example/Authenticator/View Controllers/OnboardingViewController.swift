//
//  ViewController.swift
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
    static let buttonHeight: CGFloat = 42.0
    static let buttonBottomOffset: CGFloat = 30.0
    static let buttonSideOffset: CGFloat = 30.0
    static let featuresViewBottomMultiplier: CGFloat = 0.25
}

final class OnboardingViewController: BaseViewController {
    private let featuresView = OnboardingFeaturesView()
    private let skipButton = UIButton(frame: .zero)
    private let getStartedButton = CustomButton(.filled, text: l10n(.getStarted))

    var donePressedClosure: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        featuresView.delegate = self
        setupButtons()
        layout()
    }
}

// MARK: - Setup
private extension OnboardingViewController {
    func setupButtons() {
        skipButton.setTitle(l10n(.skip), for: .normal)
        skipButton.setTitleColor(.auth_blue, for: .normal)
        skipButton.setTitleColor(.auth_lightGray50, for: .highlighted)
        skipButton.titleLabel?.font = .auth_19regular
        skipButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        getStartedButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        getStartedButton.alpha = 0.0
    }
}

// MARK: - Actions
extension OnboardingViewController {
    @objc private func done() {
        donePressedClosure?()
    }
}

// MARK: - Layout
extension OnboardingViewController: Layoutable {
    func layout() {
        view.addSubviews(featuresView, skipButton, getStartedButton)

        featuresView.top(to: view)
        featuresView.width(to: view)
        featuresView.centerX(to: view)
        featuresView.bottom(to: view, offset: -view.height * Layout.featuresViewBottomMultiplier)

        [skipButton, getStartedButton].forEach {
            $0.bottom(to: view, offset: -Layout.buttonBottomOffset)
            $0.left(to: view, offset: Layout.buttonSideOffset)
            $0.right(to: view, offset: -Layout.buttonSideOffset)
        }
        skipButton.height(to: getStartedButton)
    }
}

// MARK: - FeaturesViewDelegate
extension OnboardingViewController: FeaturesViewDelegate {
    func swipedToLastPage() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.skipButton.alpha = 0.0
                self.getStartedButton.alpha = 1.0
            }
        )
    }
}
