//
//  StackViewExtensionsSpec
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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

import Quick
import Nimble
import UIKit

class StackViewExtensionsSpec: BaseSpec {
    override func spec() {
        let stackView = UIStackView()

        describe("init()") {
            it("should initialize an stackView with given properties") {
                let axis = NSLayoutConstraint.Axis.vertical
                let alignment = UIStackView.Alignment.fill
                let spacing: CGFloat = 15.0
                let distribution = UIStackView.Distribution.equalSpacing
                stackView.axis = axis
                stackView.alignment = alignment
                stackView.spacing = spacing
                stackView.distribution = distribution
                stackView.translatesAutoresizingMaskIntoConstraints = false

                let actualStackView = UIStackView(axis: axis, alignment: alignment, spacing: spacing, distribution: distribution)

                expect(stackView.axis).to(equal(actualStackView.axis))
                expect(stackView.alignment).to(equal(actualStackView.alignment))
                expect(stackView.spacing).to(equal(actualStackView.spacing))
                expect(stackView.distribution).to(equal(actualStackView.distribution))
            }
        }

        describe("removeAllArrangedSubviews") {
            it("should remove all arranged subviews of stackView") {
                stackView.addArrangedSubviews(UIView(), UIView())

                expect(stackView.arrangedSubviews.count).to(equal(2))

                stackView.removeAllArrangedSubviews()

                expect(stackView.arrangedSubviews).to(beEmpty())
            }
        }

        describe("addArrangedSubviews") {
            it("should add subviews to stackView") {
                let firstView = UIView()
                let secondView = UIView()
                let thirdView = UIView()
                stackView.addArrangedSubviews(firstView, secondView, thirdView)

                expect(stackView.arrangedSubviews).to(equal([firstView, secondView, thirdView]))
            }
        }
    }
}

