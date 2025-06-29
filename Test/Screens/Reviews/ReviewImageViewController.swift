import UIKit

class ReviewImageViewController: UIViewController {
    private lazy var reviewImageView = ReviewImageView()
    private let images: [UIImage]
    private var currentIndex: Int
    
    init(images: [UIImage], initialIndex: Int = 0) {
        self.images = images
        self.currentIndex = initialIndex
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = reviewImageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallback()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupImages()
    }
    
}

private extension ReviewImageViewController {
    
    func setupImages() {
        reviewImageView.scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let scrollViewWidth = reviewImageView.scrollView.bounds.width
        let scrollViewHeight = reviewImageView.scrollView.bounds.height
        reviewImageView.scrollView.contentSize = CGSize(
            width: scrollViewWidth * CGFloat(images.count),
            height: scrollViewHeight
        )
        
        for (index, image) in images.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(
                x: reviewImageView.scrollView.bounds.width * CGFloat(index),
                y: 0,
                width: scrollViewWidth,
                height: scrollViewHeight
            )
            imageView.image = image
            reviewImageView.scrollView.addSubview(imageView)
        }
        
        reviewImageView.pageControl.numberOfPages = images.count
        reviewImageView.pageControl.currentPage = currentIndex
        
        reviewImageView.scrollView.contentOffset = CGPoint(
            x: reviewImageView.scrollView.bounds.width * CGFloat(currentIndex),
            y: 0
        )
    }
    
    func setupCallback() {
        reviewImageView.onCloseTap = { [weak self] in
            self?.dismiss(animated: true)
        }
        reviewImageView.scrollView.delegate = self
    }
}

extension ReviewImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.bounds.width)
        reviewImageView.pageControl.currentPage = Int(pageIndex)
        currentIndex = Int(pageIndex)
    }
}

