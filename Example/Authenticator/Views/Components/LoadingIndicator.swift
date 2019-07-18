//
//  LoadingIndicator.swift
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

private struct AnimationKeys {
    static let rotate: String = "transform.rotation.z"
    static let strokeEnd: String = "strokeEnd"
}

final class LoadingIndicator: UIView {
    private var shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        alpha = 0.0
    }

    func start() {
        if alpha != 1.0 {
            layer.add(rotationAnimation, forKey: AnimationKeys.rotate)
            shapeLayer.add(animateCirclePathAnimation, forKey: AnimationKeys.strokeEnd)
            alpha = 1.0
        }
    }

    func stop() {
        if alpha != 0.0 {
            alpha = 0.0
            layer.removeAnimation(forKey: AnimationKeys.rotate)
            shapeLayer.removeAnimation(forKey: AnimationKeys.strokeEnd)
        }
    }

    override func draw(_ rect: CGRect) {
        drawArc(in: rect)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension LoadingIndicator {
    func drawArc(in Rect: CGRect) {
        shapeLayer.path = ovalLinePath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.auth_cyan.cgColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.strokeEnd = 0.0

        layer.addSublayer(shapeLayer)
    }

    var ovalLinePath: CGPath {
        return UIBezierPath(ovalIn: bounds).cgPath
    }
}

// MARK: - Animations
private extension LoadingIndicator {
    var rotationAnimation: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: AnimationKeys.rotate)
        animation.toValue = CGFloat(Double.pi * 2.0)
        animation.isCumulative = true
        animation.duration = 0.7
        animation.isRemovedOnCompletion = false
        animation.repeatCount = .infinity
        return animation
    }

    var animateCirclePathAnimation: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: AnimationKeys.strokeEnd)
        animation.fromValue = 0.1
        animation.toValue = 0.75
        animation.autoreverses = true
        animation.duration = 1.2
        animation.isRemovedOnCompletion = false
        animation.repeatCount = .infinity
        return animation
    }
}
