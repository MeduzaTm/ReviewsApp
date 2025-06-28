//
//  ReviewImageView.swift
//  Test
//
//  Created by Нурик  Генджалиев   on 27.06.2025.
//

import UIKit

class ReviewImageView: UIView {

    let scrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds.inset(by: safeAreaInsets)
    }
}

private extension ReviewImageView {
    func setupView() {
        backgroundColor = .systemBackground
        setupScrollView()
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
    }
}
