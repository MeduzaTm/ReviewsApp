import UIKit

final class RootView: UIView {

    private let activityIndicatorView = CustomSpinnerIndicator(squareLength: 100)
    
    private let reviewsButton = UIButton(type: .system)
    private let onTapReviews: () -> Void

    init(onTapReviews: @escaping () -> Void) {
        self.onTapReviews = onTapReviews
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Убедимся, что индикатор правильно размещен
        activityIndicatorView.setNeedsLayout()
        activityIndicatorView.layoutIfNeeded()
    }

}

// MARK: - Private

private extension RootView {

    func setupView() {
        backgroundColor = .systemBackground
        setupActivityView()
        setupReviewsButton()
    }
    
    func setupActivityView() {
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.isHidden = true
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }

    func setupReviewsButton() {
        reviewsButton.setTitle("Отзывы", for: .normal)
        reviewsButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        
        let reviewAction = UIAction { [weak self] _ in
            self?.activityIndicatorView.isHidden = false
            self?.reviewsButton.isHidden = true
            self?.activityIndicatorView.startAnimation(delay: 0.04, replicates: 20)
            
            self?.layoutIfNeeded()
            
            DispatchQueue.global().async {
                sleep(2)
                DispatchQueue.main.async {
                    self?.activityIndicatorView.stopAnimation()
                    self?.activityIndicatorView.isHidden = true
                    self?.onTapReviews()
                    self?.reviewsButton.isHidden = false
                }
            }
        }
        
        reviewsButton.addAction(reviewAction, for: .touchUpInside)
        reviewsButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        reviewsButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        reviewsButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(reviewsButton)
        NSLayoutConstraint.activate([
            reviewsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            reviewsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    
}
