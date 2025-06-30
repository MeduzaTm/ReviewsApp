//
//  ImageCache.swift
//  Test
//
//  Created by Нурик  Генджалиев   on 26.06.2025.
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let ratingCache = NSCache<NSNumber, UIImage>()
    private let urlCache = NSCache<NSString, UIImage>()
    
    func image(for rating: Int) -> UIImage? {
        return ratingCache.object(forKey: NSNumber(value: rating))
    }
    
    func setImage(_ image: UIImage, for rating: Int) {
        ratingCache.setObject(image, forKey: NSNumber(value: rating))
    }
    
    func image(for urlString: String) -> UIImage? {
        return urlCache.object(forKey: urlString as NSString)
    }
    
    func setImage(_ image: UIImage, for urlString: String) {
        urlCache.setObject(image, forKey: urlString as NSString)
    }
    func clearCache() {
        ratingCache.removeAllObjects()
        urlCache.removeAllObjects()
    }
}

