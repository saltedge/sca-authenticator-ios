//
//  CustomActionSheetViewController.swift
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

private struct ActionSheetButtonsHeight {
    static let simpleActionSheetButtonHeight: CGFloat = 58.0
    static let cancelButtonHeight: CGFloat = 68.0
}

class CustomActionSheetViewController: BaseViewController {
    private var topConstraint: Constraint?
    var actions = [CustomActionSheetButton]() {
        didSet {
            addActionsToStackView()
        }
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0.0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    private let actionSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let cancelButton: TaptileFeedbackButton = {
        let button = TaptileFeedbackButton()
        button.setTitle(l10n(.cancel), for: .normal)
        button.setTitleColor(.auth_blue, for: .normal)
        button.titleLabel?.font = .auth_17regular
        return button
    }()

    private var allButtons: [TaptileFeedbackButton] {
        return actions + [cancelButton]
    }
    private var selectedButton: TaptileFeedbackButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        layout()
        cancelButton.addTarget(self, action: #selector(dismissActionSheet), for: .touchUpInside)
        allButtons.forEach { $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchDown) }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped(_ button: TaptileFeedbackButton) {
        selectedButton = button
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showActionSheet()
    }

    private func showActionSheet() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        UIView.animate(withDuration: 0.4) {
            guard let constraint = self.topConstraint else { return }

            constraint.constant = -self.actionSheetView.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }
    }

    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissActionSheet))
        view.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        actionSheetView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: actionSheetView)

        let currentlySelectedButton = selectedButton

        selectedButton = allButtons.first(where: { $0.frame.contains(location) })

        if selectedButton != currentlySelectedButton {
            currentlySelectedButton?.sendActions(for: .touchDragExit)
            selectedButton?.sendActions(for: .touchDown)
        }

        if recognizer.state == .ended {
            selectedButton?.sendActions(for: .touchUpInside)
        }
    }

    @objc private func dismissActionSheet() {
        dismissActionSheetWithCompletion { }
    }

    func dismissActionSheetWithCompletion(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0.4, animations: {
            guard let constraint = self.topConstraint else { return }

            constraint.constant = self.actionSheetView.height
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion: { _ in
            self.dismiss(animated: false, completion: completion)
        })
    }

    private func addActionsToStackView() {
        for action in actions {
            stackView.addArrangedSubview(action)
            action.height(ActionSheetButtonsHeight.simpleActionSheetButtonHeight)
        }
        stackView.addArrangedSubview(cancelButton)
        cancelButton.height(ActionSheetButtonsHeight.cancelButtonHeight)
    }
}

extension CustomActionSheetViewController: Layoutable {
    func layout() {
        view.addSubview(actionSheetView)
        actionSheetView.addSubview(stackView)
        actionSheetView.width(to: view)
        actionSheetView.centerX(to: view)
        topConstraint = actionSheetView.topToBottom(of: view)
        stackView.edges(to: actionSheetView)
        view.layoutIfNeeded()
    }
}
