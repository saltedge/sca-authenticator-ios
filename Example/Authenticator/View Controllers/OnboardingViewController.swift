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
    private let actionButton = CustomButton(.filled, text: l10n(.next))

    private var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0
        return stackView
    }()

    var donePressedClosure: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        featuresView.delegate = self
        setupButtons()
        layout()
    }

    @objc func printGetStarted() {
        print("geeeeet starteeed")
    }

    @objc func printNext() {
        print("neeeext")
    }
}

// MARK: - Setup
private extension OnboardingViewController {
    func setupButtons() {
        skipButton.setTitle(l10n(.skip), for: .normal)
        skipButton.contentHorizontalAlignment = .left
        skipButton.setTitleColor(.lightBlue, for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .medium)
        skipButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        actionButton.addTarget(self, action: #selector(printNext), for: .touchUpInside)
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
        view.addSubviews(featuresView, buttonsStackView)
        buttonsStackView.addArrangedSubviews(skipButton, actionButton)

        featuresView.top(to: view)
        featuresView.width(to: view)
        featuresView.centerX(to: view)
        featuresView.height(view.height * 0.68)

        skipButton.height(48.0)

        buttonsStackView.bottom(to: view, view.safeAreaLayoutGuide.bottomAnchor, offset: -8.0)
        buttonsStackView.left(to: view, offset: 32.0)
        buttonsStackView.right(to: view, offset: -32.0)
        buttonsStackView.height(48.0)
    }
}

// MARK: - FeaturesViewDelegate
extension OnboardingViewController: FeaturesViewDelegate {
    func swipedToLastPage() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 1.0,
            options: [],
            animations: {
                self.skipButton.isHidden = true
                self.actionButton.setTitle("Get Started", for: .normal)
                self.buttonsStackView.layoutIfNeeded()
            }
        )
        actionButton.addTarget(self, action: #selector(printGetStarted), for: .touchUpInside)
    }
}
