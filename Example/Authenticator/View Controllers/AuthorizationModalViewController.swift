//
//  AuthorizationModalViewController.swift
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

enum AuthorizationModalType {
    case show
    case preFetchAndShow
}

private struct Layout {
    static let loadingIndicatorSize: CGSize = CGSize(width: 80.0, height: 80.0)
    static let topBottomOffset: CGFloat = 70.0
    static let sideOffset: CGFloat = 15
}

protocol AuthorizationModalViewControllerDelegate: class {
    func denyPressed()
    func confirmPressed()
    func willBeClosed()
}

final class AuthorizationModalViewController: BaseViewController {
    weak var delegate: AuthorizationModalViewControllerDelegate?

    private let backgroundView = UIView()
    private var loadingView: ModalView?
    private let loadingIndicator = LoadingIndicator()
    private var authorizationModalView: AuthorizationModalView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(type: AuthorizationModalType = .show, viewModel: AuthorizationViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        authorizationModalView = AuthorizationModalView(presentationDelegate: self)
        authorizationModalView.delegate = self
        if type == .show, let viewModel = viewModel {
            authorizationModalView.set(with: viewModel)
        } else {
            loadingView = ModalView()
            loadingIndicator.start()
            loadingView?.backgroundColor = .white
            authorizationModalView.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBackgroundView()
        layout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackgroundView()
    }

    @objc func dismissController() {
        delegate?.willBeClosed()
        dismiss(animated: true, completion: nil)
    }

    func setAuthorization(_ viewModel: AuthorizationViewModel) {
        self.loadingView?.isHidden = true
        self.authorizationModalView.isHidden = false
        self.authorizationModalView.set(with: viewModel)
    }

    func setProcessing(text: String) {
        authorizationModalView.processing(with: text)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension AuthorizationModalViewController {
    func setupBackgroundView() {
        backgroundView.alpha = 0.0
        backgroundView.isUserInteractionEnabled = true
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backgroundView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dismissController))
        )

        view.addSubview(backgroundView)
        backgroundView.edgesToSuperview()
    }
}

// MARK: - Helpers
private extension AuthorizationModalViewController {
    func animateBackgroundView() {
        UIView.withSpringAnimation(
            damping: 0.75,
            animations: {
                self.backgroundView.alpha = 1.0
            },
            completion: nil
        )
    }
}

// MARK: - ModalViewPresentation
extension AuthorizationModalViewController: ModalViewPresentation {
    func setBackgroundAlpha(_ alpha: CGFloat) {
        backgroundView.alpha = alpha
    }

    func present(_ modalView: ModalView) {
        modalView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.withSpringAnimation(damping: 0.75, animations: {
            modalView.alpha = 1.0
            modalView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }

    func dismiss(_ modalView: ModalView) {
        UIView.withSpringAnimation(animations: {
            modalView.alpha = 0.0
            modalView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.dismissController()
        }, completion: nil)
    }
}

// MARK: - Layout
extension AuthorizationModalViewController: Layoutable {
    func layout() {
        view.addSubview(authorizationModalView)

        authorizationModalView.top(to: view, offset: Layout.topBottomOffset)
        authorizationModalView.left(to: view, offset: Layout.sideOffset)
        authorizationModalView.right(to: view, offset: -Layout.sideOffset)
        authorizationModalView.bottom(to: view, offset: -Layout.topBottomOffset)

        if let loadingView = loadingView {
            view.addSubview(loadingView)
            loadingView.addSubview(loadingIndicator)

            loadingIndicator.size(Layout.loadingIndicatorSize)
            loadingIndicator.center(in: loadingView)

            loadingView.top(to: view, offset: Layout.topBottomOffset)
            loadingView.left(to: view, offset: Layout.sideOffset)
            loadingView.right(to: view, offset: -Layout.sideOffset)
            loadingView.bottom(to: view, offset: -Layout.topBottomOffset)
        }
    }
}

// MARK: - AuthorizationModalViewDelegate
extension AuthorizationModalViewController: AuthorizationModalViewDelegate {
    func leftButtonPressed(_ view: AuthorizationModalView) {
        setProcessing(text: l10n(.processing))

        delegate?.denyPressed()
    }

    func rightButtonPressed(_ view: AuthorizationModalView) {
        setProcessing(text: l10n(.processing))

        delegate?.confirmPressed()
    }
}
