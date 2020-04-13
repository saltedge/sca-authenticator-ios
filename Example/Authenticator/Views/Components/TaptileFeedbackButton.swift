//
//  TaptileFeedbackButton.swift
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

class TaptileFeedbackButton: UIButton {
    var shadowColor: CGColor {
        return UIColor(red: 0, green: 0.485, blue: 0.85, alpha: 1).cgColor
    }

    lazy var shadowLayer: CALayer = {
        let layer = CALayer(layer: self.layer)
        layer.frame = self.layer.bounds
        layer.backgroundColor = self.shadowColor
        layer.cornerRadius = self.layer.cornerRadius
        return layer
    }()

    init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(highlight), for: [.touchDown, .touchDragInside, .touchDragEnter])
        addTarget(
            self,
            action: #selector(unhighlight),
            for: [.touchUpInside, .touchUpOutside, .touchDragOutside, .touchDragExit, .touchCancel]
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func highlight() {
        layer.addSublayer(self.shadowLayer)
    }

    @objc private func unhighlight() {
        shadowLayer.removeFromSuperlayer()
    }
}
