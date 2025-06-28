import UIKit

final class RootView: UIView {

    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
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

}

// MARK: - Private

private extension RootView {

    func setupView() {
        backgroundColor = .systemBackground
        setupReviewsButton()
        setupActivityView()
    }

    func setupReviewsButton() {
        reviewsButton.setTitle("Отзывы", for: .normal)
        reviewsButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        let reviewAction = UIAction { [weak self] _ in
            self?.activityIndicatorView.startAnimating()
            self?.reviewsButton.isHidden = true
            
            DispatchQueue.global().async {
                sleep(2)
                DispatchQueue.main.async {
                    self?.activityIndicatorView.stopAnimating()
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
    
    func setupActivityView() {
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
