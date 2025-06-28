import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?
    
    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    
    private var cellHeightCache: [UUID: CGFloat] = [:]
    private var countItemHeight: CGFloat?
    private var isLoading = false

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad && !isLoading else { return }
        isLoading = true
        reviewsProvider.getReviews(offset: state.offset) { [weak self] result in
            self?.isLoading = false
            self?.gotReviews(result)
        }
    }
    
    func refreshData() {
        state = State()
        cellHeightCache.removeAll()
        countItemHeight = nil
        
        getReviews()
    }
}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            
            if state.offset + state.limit >= reviews.count {
                state.items.append(makeReviewCountItem(reviews))
            }
            
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
        } catch {
            state.shouldLoad = true
        }
        onStateChange?(state)
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        cellHeightCache[item.id] = nil
        onStateChange?(state)
    }
}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let avatarImageView = UIImage(named: "profile_image")!
        let ratingImageView: UIImage
        
        if let cachedRatingImage = ImageCache.shared.image(for: review.rating) {
            ratingImageView = cachedRatingImage
        } else {
            ratingImageView = ratingRenderer.ratingImage(review.rating)
            ImageCache.shared.setImage(ratingImageView, for: review.rating)
        }
        
        let reviewsImageView: [UIImage] = review.reviewPhotos.compactMap { UIImage(named: $0) }
        
        let firstNameText = TextAttributesCache.shared.attributedString(
            for: review.firstName,
            font: .boldSystemFont(ofSize: 17)
        )
        
        let lastNameText = TextAttributesCache.shared.attributedString(
            for: review.lastName,
            font: .boldSystemFont(ofSize: 17)
        )
        
        let reviewText = TextAttributesCache.shared.attributedString(
            for: review.text,
            font: .text
        )
        
        let created = TextAttributesCache.shared.attributedString(
            for: review.created,
            font: .created,
            color: .created
        )
        
        let item = ReviewItem(
            avatarImage: avatarImageView,
            ratingImage: ratingImageView,
            reviewImages: reviewsImageView,
            firstName: firstNameText,
            lastName: lastNameText,
            reviewText: reviewText,
            created: created,
            onTapShowMore: showMoreReview
        )
        return item
    }
    
    typealias ReviewCountItem = ReviewsCountCellConfig
    
    func makeReviewCountItem(_ reviews: Reviews) -> ReviewCountItem {
        let count = reviews.count
        let textColor = UIColor.lightGray
        let textFont = UIFont.systemFont(ofSize: 17)
        let item = ReviewCountItem(
            count: count,
            textColor: textColor,
            font: textFont
        )
        return item
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: config).reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {
    
    private func clearHeightCache() {
        cellHeightCache.removeAll()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let config = state.items[indexPath.row]
        
        if let reviewItem = config as? ReviewItem {
            if let cachedHeight = cellHeightCache[reviewItem.id] {
                return cachedHeight
            }
            let height = reviewItem.height(with: tableView.bounds.size)
            cellHeightCache[reviewItem.id] = height
            return height
        }
        else if config is ReviewCountItem {
            if let height = countItemHeight {
                return height
            }
            let height = config.height(with: tableView.bounds.size)
            countItemHeight = height
            return height
        }
        
        return UITableView.automaticDimension
    }
    

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.getReviews()
            }
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}

// MARK: - UIScrollViewDelegate

extension ReviewsViewModel: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}
