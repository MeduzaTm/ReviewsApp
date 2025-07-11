import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.navigationDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.getReviews()
        setupLoading()
    }
}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        reviewsView.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak self] reviewsView in
            DispatchQueue.main.async {
                self?.reviewsView.tableView.reloadData()
            }
        }
    }
    
    func setupLoading() {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.reviewsView.activityIndicatorView.isHidden = false
                    self?.reviewsView.activityIndicatorView.startAnimation(delay: 0.04, replicates: 12)
                } else {
                    self?.reviewsView.activityIndicatorView.isHidden = true
                    self?.reviewsView.activityIndicatorView.stopAnimation()
                }
            }
        }
    }
    
    @objc func refreshData() {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.refreshData()
            self?.reviewsView.refreshControl.endRefreshing()
        }
    }
}

extension ReviewsViewController: ReviewsNavigationDelegate {
    func showImageView(images: [UIImage], initialIndex: Int) {
        let vc = ReviewImageViewController(images: images, initialIndex: initialIndex)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
