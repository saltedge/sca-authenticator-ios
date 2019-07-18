//
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

final class TimeLeftIndicator: UIView {
    private var innerCircleShapeLayer = CAShapeLayer()
    private var percentage: CGFloat

    init(frame: CGRect = .zero, percentage: CGFloat) {
        self.percentage = percentage
        super.init(frame: frame)
        backgroundColor = .white
    }

    override func draw(_ rect: CGRect) {
        drawBackgroundCircle(in: rect)
        drawInnerCircle(in: rect)
    }

    func update(with percentage: CGFloat) {
        self.percentage = percentage
        innerCircleShapeLayer.path = newPath(with: percentage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension TimeLeftIndicator {
    func drawBackgroundCircle(in rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.auth_lightCyan.cgColor
        layer.addSublayer(shapeLayer)
    }

    func newPath(with percentage: CGFloat) -> CGPath {
        let halfSize = bounds.width / 2
        let center = CGPoint(x: halfSize, y: halfSize)
        let startAngle = CGFloat(Double.pi * 3 / 2)
        let endAngle = CGFloat(startAngle + CGFloat(Double.pi) * 2 * percentage)
        let circlePath = UIBezierPath()
        circlePath.move(to: center)
        circlePath.addArc(withCenter: center, radius: halfSize - 2.0,
                          startAngle: startAngle, endAngle: endAngle, clockwise: false)
        circlePath.close()

        return circlePath.cgPath
    }

    func drawInnerCircle(in rect: CGRect) {
        innerCircleShapeLayer.path = newPath(with: percentage)
        innerCircleShapeLayer.fillColor = UIColor.auth_cyan.cgColor
        layer.addSublayer(innerCircleShapeLayer)
    }
}
