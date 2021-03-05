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
    static let titleLabelHeight: CGFloat = 28.0
    static let interSymbolsSpacing: CGFloat = 25.0
    static let passcodeSymbolsTopOffset: CGFloat = AppLayout.screenHeight * 0.02
    static let passcodeSymbolSize: CGSize = CGSize(width: 15.0, height: 15.0)
    static let wrongPasscodeLabelTopOffset: CGFloat = AppLayout.screenHeight * 0.05
    static let wrongPasscodeLabelWidth: CGFloat = AppLayout.screenWidth * 0.54
    static let wrongPasscodeLabelHeight: CGFloat = AppLayout.screenHeight * 0.054
    static let passcodeKeyboardBottomOffset: CGFloat = -AppLayout.screenHeight * 0.06
    static let passcodeKeyboardSideOffset: CGFloat = 16.0
}

protocol PasscodeViewDelegate: class {
    func completed()
    func biometricsPressed()
    func wrongPasscode()
}

final class PasscodeView: UIView {
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
        label.layer.cornerRadius = Layout.wrongPasscodeLabelHeight / 2
        label.font = .systemFont(ofSize: 14.0, weight: .regular)
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()

    private var viewModel: PasscodeViewModel

    init(viewModel: PasscodeViewModel) {
        self.viewModel = viewModel
        self.passcodeKeyboard = PasscodeKeyboard(shouldShowTouchID: viewModel.shouldShowIcon)
        super.init(frame: .zero)
        titleLabel.text = viewModel.title
        setupPasscodeSymbolsView()
        passcodeKeyboard.delegate = self
        layout()
        stylize()
        handleViewModelState()
    }

     private func handleViewModelState() {
        viewModel.state.valueChanged = { value in
            switch value {
            case let .wrong(text):
                self.wrongPasscodeLabel.text = text
                self.animateWrongPasscodeLabel()
                self.passcodeSymbols.forEach { $0.animateEmpty() }
                self.wrongPasscodeAnimation()
                self.passcodeKeyboard.showClearButton = false
                HapticFeedbackHelper.produceErrorFeedback()
            case .create(let text):
                self.animateLabel(with: text)
                self.passcodeSymbols.forEach { $0.animateEmpty() }
            case .repeat:
                self.animateLabel(with: l10n(.confirmPasscode))
                self.passcodeSymbols.forEach { $0.animateEmpty() }
            case .correct:
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
    func animateWrongPasscodeLabel() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.wrongPasscodeLabel.alpha = 1.0
            },
            completion: { _ in
                after(3.0) {
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self.wrongPasscodeLabel.alpha = 0.0
                        }
                    )
                }
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
    func keyboard(didInputDigit digit: String) {
        viewModel.didInput(
            digit: digit,
            indexToAnimate: { index in
                self.passcodeSymbols[index].animateCircle()
            }
        )
        if viewModel.isInEnterMode, viewModel.enteredDigitsCount > 0 {
            passcodeKeyboard.showClearButton = true
        }
    }

    func forgotPressed() {
        viewModel.forgotPressed()
    }

    func clearPressed() {
        viewModel.clearPressed(
            indexToAnimate: { index in
                self.passcodeSymbols[index].animateEmpty()
            }
        )
        if viewModel.isInEnterMode, viewModel.enteredDigitsCount == 0 {
            passcodeKeyboard.showClearButton = false
        }
    }

    func biometricsPressed() {
        // TODO: Move to view model when biometrics permision will be available
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
        titleLabel.height(Layout.titleLabelHeight)

        passcodeSymbolsView.topToBottom(of: titleLabel, offset: Layout.passcodeSymbolsTopOffset)
        passcodeSymbolsView.height(Layout.passcodeSymbolSize.height)
        passcodeSymbolsView.centerX(to: self)

        passcodeSymbolsView.addSubview(passcodeSymbolsStackView)

        passcodeSymbolsStackView.edges(to: passcodeSymbolsView)
        passcodeSymbolsStackView.spacing = Layout.interSymbolsSpacing

        wrongPasscodeLabel.topToBottom(of: passcodeSymbolsView, offset: Layout.wrongPasscodeLabelTopOffset)
        wrongPasscodeLabel.centerX(to: self)
        wrongPasscodeLabel.width(Layout.wrongPasscodeLabelWidth)
        wrongPasscodeLabel.height(Layout.wrongPasscodeLabelHeight)

        passcodeKeyboard.left(to: self, offset: Layout.passcodeKeyboardSideOffset)
        passcodeKeyboard.right(to: self, offset: -Layout.passcodeKeyboardSideOffset)
        passcodeKeyboard.bottomToSuperview(offset: Layout.passcodeKeyboardBottomOffset)
    }
}

// MARK: - Styleable
extension PasscodeView: Styleable {
    func stylize() {
        titleLabel.font = .systemFont(ofSize: 19.0, weight: .regular)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .titleColor
    }
}
