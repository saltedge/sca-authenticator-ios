//
//  SetupAppViewController.swift
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

// TODO: REMOVE!!
import UIKit
import TinyConstraints
import UserNotifications

private struct Layout {
    static let progressBarTopOffset: CGFloat = 52.0
    static let progressBarSideOffset: CGFloat = 30.0
    static let titleLabelTopOffset: CGFloat = 43.0
    static let labelsSideOffset: CGFloat = 30.0
    static let descriptionLabelTopOffset: CGFloat = 17.0
    static let infoViewsTopOffset: CGFloat = 15.0
    static let signUpCompleteViewTopOffset: CGFloat = 90.0
}

protocol SetupAppViewControllerDelegate: class {
    func allowBiometricsPressed()
    func allowNotificationsViewAction()
    func procceedPressed()
}

final class SetupAppViewController: BaseViewController {
    private var step: SetupStep = .createPasscode

    private var progressBar: SetupProgressBar
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .auth_darkGray
        label.font = .auth_19semibold
        label.textAlignment = .center
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_15regular
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .auth_darkGray
        return label
    }()

    private var currentView = UIView()
//    private let passcodeView = PasscodeView(purpose: .create)
    private var allowBiometricsView: InfoView
    private var allowNotificationView: InfoView
    private var signUpCompleteView: InfoView

    private var views = [UIView]()

    weak var delegate: SetupAppViewControllerDelegate?

    init() {
        progressBar = SetupProgressBar()
        allowBiometricsView = InfoView(
            image: BiometricsPresenter.onboardingImage ?? UIImage(),
            mainButtonText: BiometricsPresenter.allowText,
            secondaryButtonText: l10n(.skip)
        )
        allowNotificationView = InfoView(
            image: #imageLiteral(resourceName: "Notification"),
            mainButtonText: l10n(.allowNotifications),
            secondaryButtonText: l10n(.notNow)
        )
        signUpCompleteView = InfoView(
            image: #imageLiteral(resourceName: "Done"),
            mainButtonText: l10n(.proceed)
        )
        super.init(nibName: nil, bundle: nil)

        views = [UIView(), allowBiometricsView, allowNotificationView, signUpCompleteView]
//        passcodeView.delegate = self
        [allowBiometricsView, allowNotificationView, signUpCompleteView].forEach { $0.delegate = self }
        views.forEach { $0.alpha = 0.0 }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if step == .createPasscode {
            progressBar.animate(to: step)
            animate(to: step)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
private extension SetupAppViewController {
    func view(for step: SetupStep) -> UIView {
        switch step {
        case .createPasscode: return UIView()
        case .allowBiometricsUsage: return allowBiometricsView
        case .allowNotifications: return allowNotificationView
        case .signUpComplete: return signUpCompleteView
        }
    }
}

// MARK: - Animations
private extension SetupAppViewController {
    func animate(label: UILabel, for step: SetupStep) {
        let text = label == titleLabel ? step.title : step.description
        animate(
            view: label,
            completion: {
                label.text = text
                UIView.animate(
                    withDuration: 0.6,
                    delay: 0.3,
                    options: .curveEaseIn,
                    animations: {
                        label.alpha = 1.0
                    },
                    completion: nil
                )
            }
        )
    }

    func animate(to step: SetupStep) {
        animate(label: titleLabel, for: step)
        animate(label: descriptionLabel, for: step)
        animateCurrentView(to: step)
    }

    func animateCurrentView(to step: SetupStep) {
        animate(
            view: currentView,
            completion: {
                let newView = self.view(for: step)
                UIView.animate(
                    withDuration: 0.6,
                    animations: {
                        newView.alpha = 1.0
                    }
                )
                self.currentView = newView
            }
        )
    }

    func animate(view: UIView, completion: @escaping () -> ()) {
        UIView.transition(
            with: view,
            duration: 0.6,
            options: .curveEaseOut,
            animations: {
                view.alpha = 0.0
            },
            completion: { _ in
                completion()
            }
        )
    }
}

// MARK: Actions
extension SetupAppViewController {
    func switchToNextStep() {
        switch step {
        case .createPasscode: step = .allowBiometricsUsage
        case .allowBiometricsUsage: step = .allowNotifications
        case .allowNotifications: step = .signUpComplete
        case .signUpComplete: break
        }
        progressBar.animate(to: step)
        animate(to: step)
    }
}

// MARK: - Layout
extension SetupAppViewController: Layoutable {
    func layout() {
        view.addSubviews(progressBar, titleLabel, descriptionLabel)
        view.addSubviews(views)

        progressBar.left(to: view, offset: Layout.progressBarSideOffset)
        progressBar.right(to: view, offset: -Layout.progressBarSideOffset)
        progressBar.top(to: view, offset: Layout.progressBarTopOffset)
        progressBar.height(12.0)

        titleLabel.left(to: view, offset: Layout.labelsSideOffset)
        titleLabel.right(to: view, offset: -Layout.labelsSideOffset)
        titleLabel.topToBottom(of: progressBar, offset: Layout.titleLabelTopOffset)
        titleLabel.height(24.0)

        descriptionLabel.left(to: view, offset: Layout.labelsSideOffset)
        descriptionLabel.right(to: view, offset: -Layout.labelsSideOffset)
        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionLabelTopOffset)
        descriptionLabel.height(60.0)

        views.forEach {
            $0.left(to: view)
            $0.right(to: view)
            $0.topToBottom(of: descriptionLabel, offset: Layout.infoViewsTopOffset)
            $0.bottom(to: view)
        }

        view.layoutIfNeeded()
        progressBar.setupXPositionForCircles()
    }
}

// MARK: - InfoViewDelegate
extension SetupAppViewController: InfoViewDelegate {
    func mainButtonPressed(_ view: InfoView) {
        switch view {
        case allowBiometricsView: delegate?.allowBiometricsPressed()
        case allowNotificationView: delegate?.allowNotificationsViewAction()
        case signUpCompleteView: delegate?.procceedPressed()
        default: break
        }
    }

    func secondaryButtonPressed(_ view: InfoView) {
        switchToNextStep()
    }
}

// MARK: - PasscodeViewDelegate
extension SetupAppViewController: PasscodeViewDelegate {
    func wrongPasscode() {}

    func biometricsPressed() {}

    func passwordCorrect() {}

    func completed() {
        switchToNextStep()
    }
}
