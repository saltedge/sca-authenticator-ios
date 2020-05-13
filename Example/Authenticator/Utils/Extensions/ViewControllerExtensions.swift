//
//  ViewControllerExtensions.swift
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
import MessageUI

enum Presentation {
    case push
    case modal
}

protocol Layoutable {
    func layout()
}

protocol Styleable {
    func stylize()
}

extension UIViewController {
    func showConfirmationAlert(withTitle title: String,
                               message: String? = nil,
                               confirmActionTitle: String = l10n(.delete),
                               confirmActionStyle: UIAlertAction.Style = .destructive,
                               cancelTitle: String = l10n(.cancel),
                               confirmAction: ((UIAlertAction) -> ())? = nil,
                               cancelAction: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .lightBlue
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction)
        alert.addAction(cancelAction)
        if confirmAction != nil {
            let action = UIAlertAction(title: confirmActionTitle, style: confirmActionStyle, handler: confirmAction)
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }

    func showInfoAlert(withTitle title: String,
                       message: String? = nil,
                       actionTitle: String = l10n(.done),
                       completion: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .lightBlue
        let cancelAction = UIAlertAction(title: actionTitle, style: .cancel, handler: { _ in completion?() })
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    func showSupportMailComposer(withEmail supportEmail: String = "") {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.navigationBar.tintColor = .white
            mailVC.navigationBar.titleTextAttributes = ([.foregroundColor: UIColor.white])
            mailVC.mailComposeDelegate = self

            let email = supportEmail.isEmpty ? AppSettings.supportEmail : supportEmail

            mailVC.setToRecipients([email])
            present(mailVC, animated: true, completion: nil)
        } else {
            showConfirmationAlert(withTitle: l10n(.warning), message: l10n(.couldNotSendMail))
        }
    }
}

// MARK: MFMailComposeViewControllerDelegate
extension UIViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: {
            if result == .sent {
                self.showConfirmationAlert(withTitle: l10n(.thankYouForFeedback), cancelTitle: l10n(.ok))
            }
        })
    }
}

// MARK: - Message Bar View Presentation
extension UIViewController {
    @discardableResult
    func present(message: String,
                 style: MessageBarView.Style,
                 height: CGFloat? = nil,
                 hide: Bool = true,
                 completion: (() ->())? = nil) -> MessageBarView? {
        guard isViewLoaded && view.window != nil else { return nil } // View is not loaded or not on screen at the moment

        let messageView = MessageBarView(description: message, style: style)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addSubview(messageView)
        messageView.addGestureRecognizer(gesture)
        messageView.alpha = 0.0
        messageView.left(to: view)
        messageView.width(to: view)
        messageView.heightConstraint?.constant = 0.0
        if #available(iOS 11.0, *) {
            messageView.top(to: view, view.safeAreaLayoutGuide.topAnchor)
        } else {
            messageView.top(to: view)
        }
        view.layoutIfNeeded()
        animateMessageView(messageView, height: height ?? messageView.defaultHeight, hide: hide, completion: completion)

        return messageView
    }

    private func animateMessageView(_ messageView: MessageBarView, height: CGFloat, hide: Bool, completion: (() ->())? = nil) {
        messageView.heightConstraint?.constant = height
        UIView.withSpringAnimation(
            animations: {
                messageView.alpha = 1.0
                self.view.layoutIfNeeded()
            },
            completion: {
                after(MessageBarView.defaultDuration) {
                    completion?()
                    if hide { self.dismiss(messageBarView: messageView) }
                }
            }
        )
    }

    @objc private func dismissView(_ recognizer: UITapGestureRecognizer) {
        guard let messageView = recognizer.view as? MessageBarView else { return }

        dismiss(messageBarView: messageView)
    }

    func dismiss(messageBarView: MessageBarView) {
        guard messageBarView.superview != nil else { return }

        messageBarView.heightConstraint?.constant = 0.0

        UIView.withSpringAnimation(
            animations: {
                messageBarView.alpha = 0.0
                self.view.layoutIfNeeded()
            },
            completion: {
                messageBarView.removeFromSuperview()
            }
        )
    }
}

// MARK: - Child view controller helper
extension UIViewController {
    func add(_ child: UIViewController) {
        view.addSubview(child.view)
        child.view.edgesToSuperview()
        addChild(child)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }

    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        addChild(newViewController)
        add(newViewController)

        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .transitionFlipFromLeft,
            animations: {
                newViewController.view.alpha = 1
                oldViewController.view.alpha = 0
            },
            completion: { _ in
                oldViewController.remove()
                newViewController.didMove(toParent: self)
            }
        )
    }
}
