//
//  ImageCache.swift
//  Test
//
//  Created by Нурик  Генджалиев   on 26.06.2025.
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSNumber, UIImage>()
    
    func image(for rating: Int) -> UIImage? {
        return cache.object(forKey: NSNumber(value: rating))
    }
    
    func setImage(_ image: UIImage, for rating: Int) {
        cache.setObject(image, forKey: NSNumber(value: rating))
    }
}

