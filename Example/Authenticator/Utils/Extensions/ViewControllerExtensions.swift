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

    func showAlertViewWithInput(title: String,
                                message: String = "",
                                placeholder: String = "",
                                text: String = "",
                                action: @escaping (String) -> (),
                                actionTitle: String = l10n(.ok)
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var okAction: UIAlertAction?

        let observer = NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alertController.textFields?.first,
            queue: OperationQueue.main
        ) { _ in
            if let textField = alertController.textFields?.first,
                let text = textField.text {
                let trimmedText = text.trimmingCharacters(in: .whitespaces)
                okAction?.isEnabled = !trimmedText.isEmpty
            }
        }

        okAction = UIAlertAction(
            title: actionTitle,
            style: .default,
            handler: { _ in
                if let textField = alertController.textFields?.first, let text = textField.text, !text.isEmpty {
                    action(text)
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        )
        okAction?.isEnabled = false

        alertController.addTextField { textField in
            textField.placeholder = placeholder
            textField.textAlignment = .left
            textField.font = UIFont.systemFont(ofSize: 14.0)
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }

        if let okAction = okAction {
            alertController.addAction(okAction)
        }

        let action = UIAlertAction(
            title: l10n(.cancel),
            style: .cancel,
            handler: { _ in
                NotificationCenter.default.removeObserver(observer)
            }
        )
        alertController.addAction(action)

        present(alertController, animated: true)
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
    func present(
        message: String,
        hide: Bool = true,
        completion: (() ->())? = nil
    ) -> MessageBarView? {
        guard isViewLoaded && view.window != nil else { return nil } // View is not loaded or not on screen at the moment

        let messageView = MessageBarView(description: message)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addSubview(messageView)
        messageView.addGestureRecognizer(gesture)
        messageView.alpha = 0.0
        messageView.widthToSuperview(offset: -64.0)
        messageView.centerXToSuperview()
        messageView.bottom(to: view, view.safeAreaLayoutGuide.bottomAnchor, offset: -24.0)
        messageView.heightConstraint?.constant = 0.0

        view.layoutIfNeeded()
        animateMessageView(messageView, height: messageView.defaultHeight, hide: hide, completion: completion)

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

// MARK: - Pop to view controller with completion
extension UINavigationController {
    func popViewControllerWithHandler(controller: UIViewController, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToViewController(controller, animated: true)
        CATransaction.commit()
    }
}
