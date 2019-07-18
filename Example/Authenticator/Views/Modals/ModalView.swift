//
//  ModalView.swift
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

protocol ModalViewPresentation: class {
    func present(_ modalView: ModalView)
    func dismiss(_ modalView: ModalView)
}

class ModalView: UIView {
    weak var presentationDelegate: ModalViewPresentation?
    var isPresented = false

    init(presentationDelegate: ModalViewPresentation? = nil, frame: CGRect = .zero) {
        self.presentationDelegate = presentationDelegate
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 8.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        presentationDelegate?.present(self)
        isPresented = true
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        presentationDelegate?.dismiss(self)
        isPresented = false
        return super.resignFirstResponder()
    }
}
