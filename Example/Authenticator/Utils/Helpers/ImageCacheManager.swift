//
//  ImageCacheManager.swift
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

struct ImageCacheManager {
    private static let imageCache = NSCache<AnyObject, UIImage>()

    static func isImageCached(for url: URL) -> Bool {
        return imageCache.object(forKey: url.absoluteString as AnyObject) != nil
    }

    static func cache(image: UIImage?, for url: URL, completion: @escaping ((UIImage?) -> ())) {
        DispatchQueue.global(qos: .background).async {
            if let image = image {
                imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
            }

            DispatchQueue.main.async {
                completion(imageCache.object(forKey: url.absoluteString as AnyObject))
            }
        }
    }

    static func cachedImage(for url: URL, completion: @escaping (UIImage) -> ()) {
        DispatchQueue.main.async {
            if let image = imageCache.object(forKey: url.absoluteString as AnyObject) {
                completion(image)
            }
        }
    }

    static func clearCache() {
        DispatchQueue.main.async {
            self.imageCache.removeAllObjects()
        }
    }
}

extension UIImageView {
    func cachedImage(from url: URL?) {
        guard let imageUrl = url else { return }

        ImageCacheManager.cachedImage(for: imageUrl) { image in
            self.image = image
        }
    }
}
