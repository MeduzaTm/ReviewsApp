import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    let activityIndicatorView = CustomSpinnerIndicator(squareLength: 100)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
    }

}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
        setupActivityView()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(ReviewsCountCell.self, forCellReuseIdentifier: ReviewsCountCellConfig.reuseId)
        setupRefreshControl()
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
    
    func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        tableView.addSubview(refreshControl)
    }
}
