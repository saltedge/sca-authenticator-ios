//
//  ViewExtensions+Utilitarian.swift
//  Authenticator
//  
//  Copyright © 2019 Saltedge. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
}
