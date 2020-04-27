//
//  PasscodeSymbolView.swift
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

private struct AnimationsKeys {
    static let fillColor: String = "fillColor"
}

final class PasscodeSymbolView: UIView {
    private var shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundColor
    }

    func animateCircle() {
        animateFillColor(to: .lightBlue)
    }

    func animateEmpty() {
        animateFillColor(to: .lightGray)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        drawCircle(in: rect)
    }
}

// MARK: - Setup
private extension PasscodeSymbolView {
    func drawCircle(in rect: CGRect) {
        shapeLayer.path = pathForCircle(in: rect)
        shapeLayer.borderWidth = 0.5
        shapeLayer.fillColor = UIColor.lightGray.cgColor

        layer.addSublayer(shapeLayer)
    }

    func pathForCircle(in rect: CGRect) -> CGPath {
        return UIBezierPath(ovalIn: rect.insetBy(dx: 2.0, dy: 2.0)).cgPath
    }
}

// MARK: - Animations
private extension PasscodeSymbolView {
    func animateFillColor(to color: UIColor) {
        let animation = CABasicAnimation(keyPath: AnimationsKeys.fillColor)
        animation.duration = 0.15
        animation.toValue = color.cgColor
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        shapeLayer.add(animation, forKey: AnimationsKeys.fillColor)
    }
}
