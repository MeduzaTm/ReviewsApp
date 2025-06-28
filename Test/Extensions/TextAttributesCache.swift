//
//  TextAttributesCache.swift
//  Test
//
//  Created by Нурик  Генджалиев   on 26.06.2025.
//
import UIKit

final class TextAttributesCache {
    static let shared = TextAttributesCache()
    private let cache = NSCache<NSString, NSAttributedString>()
    
    private init() {}
    
    func attributedString(for text: String,
                          font: UIFont = .systemFont(ofSize: UIFont.labelFontSize),
                          color: UIColor? = nil) -> NSAttributedString {
        
        let key = "\(text)-\(font.fontName)-\(font.pointSize)-\(color?.description ?? "")" as NSString
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
        ]
        if let color {
            attributes[.foregroundColor] = color
        }
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        cache.setObject(attributedString, forKey: key)
        return attributedString
    }
}
