//
//  CustomActionSheetButton.swift
//  Authenticator
// 
//  Copyright © 2019 Saltedge. All rights reserved.
//

import UIKit

private struct CustomActionSheetButtonLayout {
    static let logoSize: CGSize = CGSize(width: 25.0, height: 25.0)
    static let logoLeftOffset: CGFloat = 15.0
    static let logoTopOffset: CGFloat = 17.0
    static let labelsOffset: CGFloat = 13.0
}

final class CustomActionSheetButton: TaptileFeedbackButton {
    private let buttonLogo = UIImageView()
    private let buttonTitle: UILabel = {
        let label = UILabel()
        label.textColor = .auth_darkGray
        label.font = .auth_17regular
        return label
    }()

    private var actionHandler: (() -> ()) = {}

    init(logo: UIImage, title: String, action: @escaping (() -> ())) {
        super.init()
        buttonLogo.image = logo
        buttonTitle.text = title
        actionHandler = action
        setupElements()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension CustomActionSheetButton {
    private func setupElements() {
        addSubviews(buttonLogo, buttonTitle)
        buttonLogo.contentMode = .scaleAspectFit
        layout()
        setBorders(for: [.bottom])
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }

    private func setupBottomSeparator() {
        let bottomSeparator = SeparatorView(axis: .horizontal)
        bottomSeparator.backgroundColor = .auth_lightGray50
        addSubview(bottomSeparator)
        bottomSeparator.edges(to: self)
    }
}

// MARK: Actions
extension CustomActionSheetButton {
    @objc private func buttonPressed() {
        actionHandler()
    }
}

// MARK: - Layout
extension CustomActionSheetButton: Layoutable {
    func layout() {
        buttonLogo.size(CustomActionSheetButtonLayout.logoSize)
        buttonLogo.left(to: self, offset: CustomActionSheetButtonLayout.logoLeftOffset)
        buttonLogo.top(to: self, offset: CustomActionSheetButtonLayout.logoTopOffset)
        buttonTitle.leftToRight(of: buttonLogo, offset: CustomActionSheetButtonLayout.labelsOffset)
        buttonTitle.centerY(to: buttonLogo)
        buttonTitle.right(to: self, offset: -CustomActionSheetButtonLayout.labelsOffset)
    }
}
