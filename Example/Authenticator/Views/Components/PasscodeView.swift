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

    weak var delegate: PasscodeViewDelegate?

    private let titleLabel = UILabel(frame: .zero)
    private let passcodeSymbolsView = UIView(frame: .zero)
    private let passcodeSymbolsStackView = UIStackView(frame: .zero)
    private var passcodeSymbols = [PasscodeSymbolView]()
    private var passcodeKeyboard: PasscodeKeyboard

    private let wrongPasscodeLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.0
        label.backgroundColor = .extraLightGray
        label.layer.cornerRadius = 22.0
        label.font = .systemFont(ofSize: 14.0, weight: .regular)
        label.layer.masksToBounds = true
        label.text = l10n(.passcodeDontMatch)
        label.textAlignment = .center
        return label
    }()

    var viewModel: PasscodeViewModel

    init(viewModel: PasscodeViewModel) {
        self.viewModel = viewModel
        self.passcodeKeyboard = PasscodeKeyboard(shouldShowTouchID: viewModel.shouldShowTouchId)
        super.init(frame: .zero)
        titleLabel.text = viewModel.title
        setupPasscodeSymbolsView()
        passcodeKeyboard.delegate = self
        layout()
        stylize()
        handleViewModelState()
    }

    func handleViewModelState() {
        viewModel.state.valueChanged = { value in
            switch value {
            case .wrongPasscode:
                self.animateWrongPasscodeLabel(show: true)
                self.wrongPasscodeAnimation()
                HapticFeedbackHelper.produceErrorFeedback()
            case .switchToCreate:
                self.animateLabel(with: l10n(.createPasscode))
                self.passcodeSymbols.forEach { $0.animateEmpty() }
            case .switchToRepeat:
                self.animateWrongPasscodeLabel(show: false)
                self.animateLabel(with: l10n(.repeatPasscode))
                self.passcodeSymbols.forEach { $0.animateEmpty() }
            case .correctPasscode:
                self.delegate?.completed()
            default: break
            }
        }
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
private extension PasscodeView {
    func animateWrongPasscodeLabel(show: Bool) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.wrongPasscodeLabel.alpha = show ? 1.0 : 0.0
            }
        )
    }

    func wrongPasscodeAnimation() {
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

// MARK: - PasscodeKeyboardDelegate
extension PasscodeView: PasscodeKeyboardDelegate {
    func keyboard(_ keyboard: PasscodeKeyboard, didInputDigit digit: String) {
        viewModel.didInput(digit: digit, symbols: passcodeSymbols)
    }

    func clearPressed(on keyboard: PasscodeKeyboard) {
        viewModel.clearPressed(symbols: passcodeSymbols)
    }

    func biometricsPressed(on keyboard: PasscodeKeyboard) {
        delegate?.biometricsPressed()
    }
}

// MARK: - Layout
extension PasscodeView: Layoutable {
    func layout() {
        addSubviews(titleLabel, passcodeSymbolsView, wrongPasscodeLabel, passcodeKeyboard)

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

        wrongPasscodeLabel.topToBottom(of: passcodeSymbolsView, offset: 46.0)
        wrongPasscodeLabel.left(to: self, offset: 86.0)
        wrongPasscodeLabel.right(to: self, offset: -86.0)
        wrongPasscodeLabel.height(44.0)

        passcodeKeyboard.topToBottom(of: wrongPasscodeLabel, offset: 67.0)
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
