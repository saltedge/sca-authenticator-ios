//
//  AuthorizationsHeaderCollectionViewCell
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

struct AuthorizationCellViewModel {
    let name: String
    let expiresAt: Date
    let lifetime: Int
    let logoUrl: URL?
    let completionBlock: (() -> ())?
}

protocol AuthorizationHeaderCellDelegate: class {
    func timerExpired(cell: AuthorizationHeaderCollectionViewCell)
}

final class AuthorizationHeaderCollectionViewCell: UICollectionViewCell {
    private let connectionImageView = UIImageView()
    private let connectionNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        return label
    }()
    private var timeLeftLabel: TimeLeftView!

    weak var delegate: AuthorizationHeaderCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        timeLeftLabel = TimeLeftView(
            secondsLeft: 0,
            lifetime: 0,
            completion: { [weak self] in
                guard let weakSelf = self else { return }

                weakSelf.delegate?.timerExpired(cell: weakSelf)
            }
        )
        setupShadowAndCornerRadius()
        layout()
    }

    func configure(_ item: AuthorizationViewModel, at indexPath: IndexPath) {
        connectionImageView.contentMode = .scaleAspectFit
        connectionImageView.image = #imageLiteral(resourceName: "bankPlaceholderCyanSmall")

        if let connection = ConnectionsCollector.with(id: item.connectionId) {
            setImage(from: connection.logoUrl)
            connectionNameLabel.text = connection.name
        }
        timeLeftLabel.update(
            secondsLeft: diffInSecondsFromNow(for: item.authorizationExpiresAt),
            lifetime: item.lifetime
        )
    }

    private func setupShadowAndCornerRadius() {
        layer.cornerRadius = 20.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setImage(from imageUrl: URL?) {
        guard let url = imageUrl else { return }

        ConnectionImageHelper.setAnimatedCachedImage(from: url, for: connectionImageView)
    }
}

extension AuthorizationHeaderCollectionViewCell: Layoutable {
    func layout() {
        addSubviews(connectionImageView, connectionNameLabel, timeLeftLabel)

        connectionImageView.left(to: self, offset: 16.0)
        connectionImageView.centerY(to: self)
        connectionImageView.size(CGSize(width: 24.0, height: 24.0))

        connectionNameLabel.leftToRight(of: connectionImageView, offset: 8.0)
        connectionNameLabel.centerY(to: connectionImageView)

        timeLeftLabel.right(to: self, offset: -8.0)
        timeLeftLabel.centerY(to: connectionImageView)
        timeLeftLabel.height(28.0)
    }
}

private extension AuthorizationHeaderCollectionViewCell {
    func diffInSecondsFromNow(for date: Date) -> Int {
        let currentDate = Date()
        let diffDateComponents = Calendar.current.dateComponents([.minute, .second], from: currentDate, to: date)

        guard let minutes = diffDateComponents.minute, let seconds = diffDateComponents.second else { return 0 }

        return 60 * minutes + seconds
    }
}
