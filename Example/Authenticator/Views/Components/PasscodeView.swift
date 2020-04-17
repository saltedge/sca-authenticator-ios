//
//  PasscodeView.swift
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
    static let titleLabelSideOffset: CGFloat = 37.0
    static let titleLabelHeight: CGFloat = 24.0
    static let interSymbolsSpacing: CGFloat = 25.0
    static let passcodeSymbolSize: CGSize = CGSize(width: 15.0, height: 15.0)
    static let logoImageViewSize: CGSize = CGSize(width: 50.0, height: 50.0)
    static let logoImageBottomOffset: CGFloat = 50.0
    static let passcodeKeyboardTopOffset: CGFloat = 56.0
    static let passcodeSymbolsTopOffset: CGFloat = 40.0
}

protocol PasscodeViewDelegate: class {
    func completed()
    func passwordCorrect()
    func biometricsPressed()
    func wrongPasscode()
}

final class PasscodeView: UIView {
    enum Purpose {
        case create
        case edit
        case enter
    }

    enum Stage {
        case first
        case second
    }

    weak var delegate: PasscodeViewDelegate?

    private var purpose: Purpose
    private var stage: Stage = .first
    private let titleLabel = UILabel(frame: .zero)
    private let passcodeSymbolsView = UIView(frame: .zero)
    private let passcodeSymbolsStackView = UIStackView(frame: .zero)
    private var passcodeSymbols = [PasscodeSymbolView]()
    private var passcodeKeyboard: PasscodeKeyboard
    private var passcode = ""
    private var confirmationPasscode = ""

    var viewModel: PasscodeViewModel

    init(purpose: Purpose) {
        self.purpose = purpose
        self.passcodeKeyboard = PasscodeKeyboard(shouldShowTouchID: purpose == .enter && PasscodeManager.isBiometricsEnabled)
        viewModel = PasscodeViewModel(purpose: purpose)
        super.init(frame: .zero)
        titleLabel.text = viewModel.title

        setupPasscodeSymbolsView()
        passcodeKeyboard.delegate = self
        layout()
        stylize()
    }

    private var title: String {
        switch purpose {
        case .create: return l10n(.createPasscode)
        case .edit: return l10n(.enterPasscode)
        case .enter:
            return PasscodeManager.isBiometricsEnabled ? BiometricsPresenter.passcodeDescriptionText : l10n(.enterPasscode)
        }
    }

    func wrongPasscode() {
        wrongPasscodeAnimation()
        HapticFeedbackHelper.produceErrorFeedback()
        passcode = ""
        confirmationPasscode = ""
        delegate?.wrongPasscode()
    }

    func switchToCreate() {
        purpose = .create
        stage = .first
        passcode = ""
        animateLabel(with: l10n(.createPasscode))
        passcodeSymbols.forEach { $0.animateEmpty() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension PasscodeView {
    func setupPasscodeSymbolsView() {
        for _ in 0...3 {
            let passcodeSymbol = PasscodeSymbolView()
            passcodeSymbol.size(Layout.passcodeSymbolSize)
            passcodeSymbols.append(passcodeSymbol)
            passcodeSymbolsStackView.addArrangedSubview(passcodeSymbol)
        }
    }

    func stageCompleted() {
        guard purpose == .create else { return checkPassword() }

        stage == .first ? switchToRepeat() : comparePasswords()
    }

    func comparePasswords() {
        guard passcode == confirmationPasscode else {
            wrongPasscode()
            switchToCreate()
            return
        }

        PasscodeManager.set(passcode: passcode)
        delegate?.completed()
    }

    func checkPassword() {
        guard passcode == PasscodeManager.current else {
            wrongPasscode()
            passcodeSymbols.forEach { $0.animateEmpty() }
            return
        }

        delegate?.passwordCorrect()
    }

    func switchToRepeat() {
        stage = .second
        animateLabel(with: l10n(.repeatPasscode))
        passcodeSymbols.forEach { $0.animateEmpty() }
    }

    func animateLabel(with text: String) {
        UIView.transition(
            with: titleLabel,
            duration: 0.6,
            options: .curveEaseOut,
            animations: {
                self.titleLabel.alpha = 0.0
            },
            completion: { _ in
                self.titleLabel.text = text
                UIView.transition(
                    with: self.titleLabel,
                    duration: 0.6,
                    options: .curveEaseOut,
                    animations: {
                        self.titleLabel.alpha = 1.0
                    }
                )
            }
        )
    }
}

// MARK: - Animations
extension PasscodeView {
    private func wrongPasscodeAnimation() {
        let springAnimation = CASpringAnimation(keyPath: "position.x")
        springAnimation.duration = springAnimation.settlingDuration
        springAnimation.fromValue = passcodeSymbolsView.layer.position.x - 40.0
        springAnimation.toValue =  passcodeSymbolsView.layer.position.x
        springAnimation.damping = 10.0
        springAnimation.initialVelocity = -10.0
        springAnimation.isRemovedOnCompletion = true
        springAnimation.stiffness = 300.0
        passcodeSymbolsView.layer.add(springAnimation, forKey: "position.x")
    }
}

// MARK: - Helpers
extension PasscodeView {
    var passcodeToFill: String {
        get {
            return stage == .first ? passcode : confirmationPasscode
        }
        set {
            if stage == .first {
                passcode = newValue
            } else {
                confirmationPasscode = newValue
            }
        }
    }
}
// MARK: - PasscodeKeyboardDelegate
extension PasscodeView: PasscodeKeyboardDelegate {
    func keyboard(_ keyboard: PasscodeKeyboard, didInputDigit digit: String) {
        if passcodeToFill.count < 3 {
            passcodeToFill.append(digit)
            passcodeSymbols[passcodeToFill.count - 1].animateCircle()
        } else {
            passcodeToFill.append(digit)
            if passcodeSymbols.indices.contains(passcodeToFill.count - 1) {
                passcodeSymbols[passcodeToFill.count - 1].animateCircle()
                after(0.1) { self.stageCompleted() }
            }
        }
    }

    func clearPressed(on keyboard: PasscodeKeyboard) {
        if passcodeToFill.count != 0 {
            passcodeToFill = String(passcodeToFill.dropLast(1))
            passcodeSymbols[passcodeToFill.count].animateEmpty()
        }
    }

    func biometricsPressed(on keyboard: PasscodeKeyboard) {
        delegate?.biometricsPressed()
    }
}

// MARK: - Layout
extension PasscodeView: Layoutable {
    func layout() {
        addSubviews(titleLabel, passcodeSymbolsView, passcodeKeyboard)

        titleLabel.topToSuperview()
        titleLabel.left(to: self, offset: Layout.titleLabelSideOffset)
        titleLabel.right(to: self, offset: -Layout.titleLabelSideOffset)
        titleLabel.height(28.0)

        passcodeSymbolsView.topToBottom(of: titleLabel, offset: 22.0)
        passcodeSymbolsView.height(Layout.passcodeSymbolSize.height)
        passcodeSymbolsView.centerX(to: self)

        passcodeSymbolsView.addSubview(passcodeSymbolsStackView)

        passcodeSymbolsStackView.edges(to: passcodeSymbolsView)
        passcodeSymbolsStackView.spacing = Layout.interSymbolsSpacing

        passcodeKeyboard.topToBottom(of: passcodeSymbolsView, offset: 117.0)
        passcodeKeyboard.left(to: self, offset: 16.0)
        passcodeKeyboard.right(to: self, offset: -16.0)
    }
}

// MARK: - Styleable
extension PasscodeView: Styleable {
    func stylize() {
        titleLabel.font = .systemFont(ofSize: 19.0, weight: .regular)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .textColor
    }
}
