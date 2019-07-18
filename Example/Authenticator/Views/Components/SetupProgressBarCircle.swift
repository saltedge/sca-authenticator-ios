//
//  SetupProgressBarCircle.swift
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
    static let strokeColor: String = "strokeColor"
    static let strokeEnd: String = "strokeEnd"
    static let opacity: String = "opacity"
}

private struct Style {
    static let backgroundColor: CGColor = UIColor.auth_lightGray50.cgColor
}

final class SetupProgressBarCircle: UIView {
    private var outerCircleShapeLayer = CAShapeLayer()
    private var innerCircleShapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    override func draw(_ rect: CGRect) {
        drawBackgroundCircle(in: rect)
        drawOuterCircle(in: rect)
        drawInnerCircle(in: rect)
        innerCircleShapeLayer.opacity = 0.0
    }

    func active() {
        animateOuterStrokeEnd()
        animateOuterFillColor()
        animateOuterStrokeColor()
    }

    func done() {
        animateInnerOpacity()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension SetupProgressBarCircle {
    func drawBackgroundCircle(in rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = Style.backgroundColor
        layer.addSublayer(shapeLayer)
    }

    func drawOuterCircle(in rect: CGRect) {
        let strokeWidth: CGFloat = 2.0
        let halfSize = width / 2

        let circlePath = UIBezierPath(arcCenter: CGPoint(x: halfSize, y: halfSize),
                                      radius: CGFloat(halfSize - (strokeWidth / 2)),
                                      startAngle: CGFloat(Double.pi),
                                      endAngle: CGFloat(Double.pi * 3),
                                      clockwise: true)

        outerCircleShapeLayer.path = circlePath.cgPath
        outerCircleShapeLayer.fillColor = Style.backgroundColor
        outerCircleShapeLayer.strokeColor = Style.backgroundColor
        outerCircleShapeLayer.lineWidth = strokeWidth
        layer.addSublayer(outerCircleShapeLayer)
    }

    func drawInnerCircle(in rect: CGRect) {
        let cirlePath = UIBezierPath(ovalIn: CGRect(x: rect.width / 3, y: rect.height / 3,
                                                    width: rect.width / 3, height: rect.height / 3))
        innerCircleShapeLayer.path = cirlePath.cgPath
        innerCircleShapeLayer.fillColor = UIColor.auth_cyan.cgColor
        layer.addSublayer(innerCircleShapeLayer)
    }
}

// MARK: - Animations
private extension SetupProgressBarCircle {
    func animateOuterFillColor() {
        outerCircleShapeLayer.fillColor = UIColor.white.cgColor
        let animation = CABasicAnimation(keyPath: AnimationsKeys.fillColor)
        animation.duration = 0.5
        animation.fromValue = Style.backgroundColor
        outerCircleShapeLayer.add(animation, forKey: AnimationsKeys.fillColor)
    }

    func animateOuterStrokeColor() {
        outerCircleShapeLayer.strokeColor = UIColor.auth_blue.cgColor
        let animation = CABasicAnimation(keyPath: AnimationsKeys.strokeColor)
        animation.duration = 0.5
        animation.fromValue = Style.backgroundColor
        outerCircleShapeLayer.add(animation, forKey: AnimationsKeys.strokeColor)
    }

    func animateOuterStrokeEnd() {
        let animation = CABasicAnimation(keyPath: AnimationsKeys.strokeEnd)
        animation.duration = 0.5
        animation.fromValue = 0.0
        outerCircleShapeLayer.add(animation, forKey: AnimationsKeys.strokeEnd)
    }

    func animateInnerOpacity() {
        innerCircleShapeLayer.opacity = 1.0
        let animation = CABasicAnimation(keyPath: AnimationsKeys.opacity)
        animation.duration = 0.5
        animation.fromValue = 0.0
        innerCircleShapeLayer.add(animation, forKey: AnimationsKeys.opacity)
    }
}
