//
//  SetupProgressBar.swift
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
    static let circleSize: CGSize = CGSize(width: 12.0, height: 12.0)
}

final class SetupProgressBar: UIView {
    private let progressBar = UIView(frame: .zero)
    private let fillBar = UIView(frame: .zero)
    private var fillBarWidthConstraint: Constraint?
    private var circles = [SetupProgressBarCircle]()

    init() {
        super.init(frame: .zero)
        setupProgressBar()
        setupCircles()
    }

    func setupXPositionForCircles() {
        for (index, circle) in circles.enumerated() {
            if index == 0 {
                circle.left(to: self)
            } else if index == 3 {
               circle.right(to: self)
            } else {
                circle.left(to: self, offset: progressBar.width / 3 * CGFloat(index))
            }
        }
    }

    func animate(to step: SetupStep) {
        switch step {
        case .createPasscode:
            circles[0].active()
        case .allowBiometricsUsage:
            circles[0].done()
            updateFillBarWidth(to: progressBar.width / 3, completion: { _ in self.circles[1].active() })
        case .allowNotifications:
            circles[1].done()
            updateFillBarWidth(to: progressBar.width / 3 * 2, completion: { _ in self.circles[2].active() })
        case .signUpComplete:
            circles[2].done()
            updateFillBarWidth(to: progressBar.width, completion: { _ in
                self.circles[3].active()
                self.circles[3].done()
            })
        }
    }

    private func updateFillBarWidth(to width: CGFloat, completion: ((UIViewAnimatingPosition) -> Void)? = nil) {
        guard let constraint = fillBarWidthConstraint else { return }

        constraint.constant = width
        let animator = UIViewPropertyAnimator(duration: 0.7, curve: .easeIn) {
            self.layoutIfNeeded()
        }
        if let completion = completion {
            animator.addCompletion(completion)
        }
        animator.startAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension SetupProgressBar {
    func setupProgressBar() {
        addSubview(progressBar)
        progressBar.centerY(to: self)
        progressBar.left(to: self, offset: Layout.circleSize.width / 2)
        progressBar.right(to: self, offset: -Layout.circleSize.width / 2)
        progressBar.height(2.0)
        progressBar.backgroundColor = .auth_lightGray50

        progressBar.addSubview(fillBar)
        fillBar.left(to: progressBar)
        fillBar.top(to: progressBar)
        fillBar.bottom(to: progressBar)
        fillBarWidthConstraint = fillBar.width(0)
        fillBar.backgroundColor = .auth_blue
    }

    func setupCircles() {
        for _ in 0...3 {
            let circle = SetupProgressBarCircle()
            addSubview(circle)
            circles.append(circle)
            circle.centerY(to: self)
            circle.size(Layout.circleSize)
        }
    }
}
