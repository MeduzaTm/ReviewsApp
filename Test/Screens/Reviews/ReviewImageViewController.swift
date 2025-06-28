//
//  ReviewImageViewController.swift
//  Test
//
//  Created by Нурик  Генджалиев   on 27.06.2025.
//

import UIKit

class ReviewImageViewController: UIViewController {
    private lazy var reviewImageView = makeImageView()
    private var viewModel: ReviewsViewModel
    
    private let images: [UIImage]
    private var currentIndex: Int
    
    init(images: [UIImage], initialIndex: Int = 0, viewModel: ReviewsViewModel) {
        self.images = images
        self.currentIndex = initialIndex
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = reviewImageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImages()
    }
    
}

private extension ReviewImageViewController {
    func makeImageView() -> ReviewImageView {
        let reviewImageView = ReviewImageView()
        reviewImageView.scrollView.delegate = viewModel
        return reviewImageView
    }
    
    func setupImages() {
        reviewImageView.scrollView.frame = view.bounds
        reviewImageView.scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(images.count),
            height: view.bounds.height
        )
        
        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(
                x: reviewImageView.scrollView.bounds.width * CGFloat(index),
                y: 0,
                width: reviewImageView.scrollView.bounds.width,
                height: reviewImageView.scrollView.bounds.height
            )
            reviewImageView.scrollView.addSubview(imageView)
        }
    }
}

