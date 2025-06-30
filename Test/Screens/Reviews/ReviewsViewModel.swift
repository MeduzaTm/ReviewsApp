import UIKit

protocol ReviewsNavigationDelegate: AnyObject {
    func showImageView(images: [UIImage], initialIndex: Int)
}

final class ReviewsViewModel: NSObject {
    
    var onStateChange: ((State) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    weak var navigationDelegate: ReviewsNavigationDelegate?
    
    @MainActor private(set) var isLoading: Bool = false {
        didSet {
            onLoadingStateChange?(isLoading)
        }
    }
    
    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    
    private var cellHeightCache: [UUID: CGFloat] = [:]
    private var countItemHeight: CGFloat?
    
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
    
    func getReviews() {
        Task { @MainActor in
            guard state.shouldLoad && !isLoading else { return }
            await MainActor.run {
                isLoading = true
            }
            do {
                let data = try await reviewsProvider.getReviews(offset: state.offset)
                gotReviews(data)
            } catch {
                handleReviewsError(error)
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func refreshData() {
        state = State()
        cellHeightCache.removeAll()
        countItemHeight = nil
        
        onStateChange?(state)
        
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let data = try await reviewsProvider.getReviews(offset: state.offset)
                gotReviews(data)
            } catch {
                handleReviewsError(error)
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
        
    }
}

// MARK: - Private

private extension ReviewsViewModel {
    
    /// Метод обработки получения отзывов.
    func gotReviews(_ data: Data) {
        do {
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map { makeReviewItem($0) }
            
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
    
    func handleReviewsError(_ error: Error) {
        state.shouldLoad = true
        onStateChange?(state)
    }
    
    @MainActor
    func finishLoading() {
        isLoading = false
    }
    
    func loadImages(from urlString: String) async -> UIImage? {
        guard !urlString.isEmpty else { return nil }
        
        do {
            let data = try await reviewsProvider.getImages(from: urlString)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    @MainActor
    func updateCell(with item: ReviewItem) {
        guard let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == item.id }) else { return }
        state.items[index] = item
        cellHeightCache[item.id] = nil
        onStateChange?(state)
    }
    
    @MainActor
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
    
    func showImageView(images: [UIImage], initialIndex: Int) {
        navigationDelegate?.showImageView(images: images, initialIndex: initialIndex)
    }
}

// MARK: - Items

private extension ReviewsViewModel {
    
    typealias ReviewItem = ReviewCellConfig
    
    func makeReviewItem(_ review: Review) -> ReviewItem {
        let itemId = review.id
        let placeholder = UIImage(named: "profile_image")!
        let ratingImageView: UIImage
        
        if let cachedRatingImage = ImageCache.shared.image(for: review.rating) {
            ratingImageView = cachedRatingImage
        } else {
            ratingImageView = ratingRenderer.ratingImage(review.rating)
            ImageCache.shared.setImage(ratingImageView, for: review.rating)
        }
        
        let reviewsImageView: [UIImage] = Array(repeating: placeholder, count: review.reviewUrls.count)
        
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
        
        var item = ReviewItem(
            id: itemId,
            avatarImage: placeholder,
            ratingImage: ratingImageView,
            reviewImages: reviewsImageView,
            firstName: firstNameText,
            lastName: lastNameText,
            reviewText: reviewText,
            created: created,
            onTapShowMore: { [weak self] id in
                Task { @MainActor in
                    self?.showMoreReview(with: id)
                }
            },
            onImageTap: { [weak self] index in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let itemIndex = self.state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == itemId }),
                       let currentItem = self.state.items[itemIndex] as? ReviewItem {
                        self.showImageView(images: currentItem.reviewImages, initialIndex: index)
                    }
                }
            }
        )
        
        if !review.avatarUrl.isEmpty {
            if let cachedImage = ImageCache.shared.image(for: review.avatarUrl) {
                item.avatarImage = cachedImage
            } else {
                let avatarUrl = review.avatarUrl
                let itemId = item.id
                
                Task {
                    let image = await loadImages(from: avatarUrl) ?? placeholder
                    await MainActor.run {
                        ImageCache.shared.setImage(image, for: avatarUrl)
                        if let currentIndex = self.state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == itemId }),
                           var currentItem = self.state.items[currentIndex] as? ReviewItem {
                            currentItem.avatarImage = image
                            self.updateCell(with: currentItem)
                        }
                    }
                }
            }
        }
        
        for (index, url) in review.reviewUrls.enumerated() {
            if let cachedImage = ImageCache.shared.image(for: url) {
                item.reviewImages[index] = cachedImage
            } else {
                let url = url
                let itemId = item.id
                let currentIndex = index
                
                Task {
                    if let image = await loadImages(from: url) {
                        await MainActor.run {
                            ImageCache.shared.setImage(image, for: url)
                            if let itemIndex = self.state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == itemId }),
                               var currentItem = self.state.items[itemIndex] as? ReviewItem,
                               currentItem.reviewImages.indices.contains(currentIndex) {
                                currentItem.reviewImages[currentIndex] = image
                                self.state.items[itemIndex] = currentItem
                                self.cellHeightCache[currentItem.id] = nil
                                self.onStateChange?(self.state)
                            }
                        }
                    }
                }
            }
        }
        
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
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
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
