import UIKit

class ReviewImageView: UIView {

    let scrollView = UIScrollView()
    let pageControl = UIPageControl()
    let closeButton = UIButton(type: .system)
    
    var onCloseTap: (() -> Void)?
    var currentPage: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
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
        pageControl.frame = CGRect(
            x: 0,
            y: safeAreaInsets.top + 20,
            width: bounds.width,
            height: 30
        )
        closeButton.frame = CGRect(
            x: bounds.width - 60,
            y: safeAreaInsets.top + 20,
            width: 40,
            height: 40
        )
    }
}

private extension ReviewImageView {
    func setupView() {
        backgroundColor = .systemBackground
        setupScrollView()
        setupPageControl()
        setupCloseButton()
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
    }
    
    func setupPageControl() {
        addSubview(pageControl)
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
    }
    
    func setupCloseButton() {
        addSubview(closeButton)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    @objc func closeTapped() {
        onCloseTap?()
    }
}
