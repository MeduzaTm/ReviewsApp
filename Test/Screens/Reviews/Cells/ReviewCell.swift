import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {
    
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)
    
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id: UUID
    /// Аватар пользователя
    var avatarImage: UIImage
    ///Рейтинг пользователя
    let ratingImage: UIImage
    ///Фото отзывов
    var reviewImages: [UIImage]
    /// Имя пользователя
    let firstName: NSAttributedString
    ///Фамилия пользователя
    let lastName: NSAttributedString
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    /// Замыкание, вызываемое при нажатии на фотографию
    let onImageTap: (Int) -> Void
    
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()
    
}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {
    
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.avatarImageView.image = avatarImage
        cell.ratingImageView.image = ratingImage
        cell.imagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview()}
        cell.firstNameLabel.attributedText = firstName
        cell.lastNameLabel.attributedText = lastName
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
        
        for (index, image) in reviewImages.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = Layout.photoCornerRadius
            imageView.image = image
            imageView.isUserInteractionEnabled = true
            imageView.tag = index
            
            cell.imagesStackView.addArrangedSubview(imageView)
        }
    }
    
    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
    
}

// MARK: - Private

private extension ReviewCellConfig {
    
    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)
    
}

// MARK: - Cell

final class ReviewCell: UITableViewCell {
    
    fileprivate var config: Config?
    
    fileprivate let avatarImageView = UIImageView()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let imagesStackView = UIStackView()
    fileprivate let firstNameLabel = UILabel()
    fileprivate let lastNameLabel = UILabel()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarFrame
        ratingImageView.frame = layout.ratingFrame
        imagesStackView.frame = layout.imageStackViewFrame
        firstNameLabel.frame = layout.firstNameLabelFrame
        lastNameLabel.frame = layout.lastNameLabelFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }
    
}

// MARK: - Private

private extension ReviewCell {
    
    func setupCell() {
        setupAvatarImageView()
        setupRatingImageView()
        setupImagesStackView()
        setupFirstNameLabel()
        setupLastNameLabel()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 18
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
        ratingImageView.contentMode = .scaleAspectFit
    }
    
    func setupImagesStackView() {
        contentView.addSubview(imagesStackView)
        imagesStackView.axis = .horizontal
        imagesStackView.spacing = 8
        imagesStackView.isUserInteractionEnabled = true
        imagesStackView.distribution = .fillEqually
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imagesStackView.addGestureRecognizer(tapGesture)
    }
    
    func setupFirstNameLabel() {
        contentView.addSubview(firstNameLabel)
    }
    
    func setupLastNameLabel() {
        contentView.addSubview(lastNameLabel)
    }
    
    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }
    
    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }
    
    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        let showAction = UIAction { [weak self] _ in
            guard let self = self, let config = self.config else { return }
            config.onTapShowMore(config.id)
        }
        showMoreButton.addAction(showAction, for: .touchUpInside)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: imagesStackView)
        guard let index = imagesStackView.arrangedSubviews.firstIndex(where: { $0.frame.contains(location) }) else { return }
        config?.onImageTap(index)
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    
    // MARK: - Размеры
    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let photoCornerRadius = 8.0
    
    fileprivate static let ratingSize = CGSize(width: 96.0, height: 24.0)
    
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let photosSpacing = 8.0
    private static let maxPhotosCount: Int = 5
    private static let showMoreButtonSize = Config.showMoreText.size()
    
    // MARK: - Фреймы
    
    private(set) var avatarFrame = CGRect.zero
    private(set) var ratingFrame = CGRect.zero
    private(set) var imageStackViewFrame = CGRect.zero
    private(set) var firstNameLabelFrame = CGRect.zero
    private(set) var lastNameLabelFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    
    // MARK: - Отступы
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    
    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Отступ между именем пользователя и фамилией пользователя
    private let nameSpacing = 4.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0
    
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    ///Возвращает размеры фото в ячейке с данным количеством `imagesCount`  и шириной `availableWidth`
    func setupImagesSize(imagesCount: Int, availableWidth: CGFloat) -> CGSize {
        guard imagesCount > 0 else { return .zero}
        
        let imagesInRow = min(imagesCount, Self.maxPhotosCount)
        let totalSpacing = CGFloat(imagesInRow - 1) * Self.photosSpacing
        let rowWidth = CGFloat(imagesInRow) * Self.photoSize.width + totalSpacing
        
        let scalingFactor = min(1, availableWidth / rowWidth)
        let scaledPhotoHeight = Self.photoSize.height * scalingFactor
        
        let rowsCount = Int(ceil(Double(imagesCount) / Double(Self.maxPhotosCount)))
        let totalHeight = CGFloat(rowsCount) * scaledPhotoHeight + CGFloat(rowsCount - 1) * Self.photosSpacing
        
        return CGSize(width: min(rowWidth, availableWidth), height: totalHeight)
        
    }
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right
        
        var maxY = insets.top
        let contentX = insets.left + Self.avatarSize.width + avatarToUsernameSpacing
        let contentAvailableWidth = width - Self.avatarSize.width - avatarToUsernameSpacing
        
        let firstNameSize = config.firstName.boundingRect(width: contentAvailableWidth).size
        let lastNameAvailableWidth = contentAvailableWidth - firstNameSize.width - nameSpacing
        let lastNameSize = config.lastName.boundingRect(width: lastNameAvailableWidth).size
        
        
        avatarFrame = CGRect(
            x: insets.left,
            y: insets.top,
            width: Self.avatarSize.width,
            height: Self.avatarSize.height
        )
        
        firstNameLabelFrame = CGRect(
            x: contentX,
            y: maxY,
            width: firstNameSize.width,
            height: firstNameSize.height
        )
        
        lastNameLabelFrame = CGRect(
            x: contentX + firstNameSize.width + nameSpacing,
            y: maxY,
            width: lastNameSize.width,
            height: lastNameSize.height
        )
        
        maxY += max(firstNameSize.height, lastNameSize.height) + usernameToRatingSpacing
        
        ratingFrame = CGRect(
            x: contentX,
            y: maxY,
            width: Self.ratingSize.width,
            height: Self.ratingSize.height
        )
        
        maxY += Self.ratingSize.height + ratingToTextSpacing
        
        var showShowMoreButton = false
        
        if !config.reviewImages.isEmpty {
            let imageSize = setupImagesSize(
                imagesCount: config.reviewImages.count,
                availableWidth: contentAvailableWidth
            )
            imageStackViewFrame = CGRect(
                x: contentX,
                y: maxY,
                width: imageSize.width,
                height: imageSize.height
            )
            maxY += imageSize.height + photosToTextSpacing
        }
        
        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: contentAvailableWidth).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
            
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: contentX, y: maxY),
                size: config.reviewText.boundingRect(width: contentAvailableWidth, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }
        
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: contentX, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
        
        createdLabelFrame = CGRect(
            origin: CGPoint(x: contentX, y: maxY),
            size: config.created.boundingRect(width: contentAvailableWidth).size
        )
        
        return createdLabelFrame.maxY + insets.bottom
    }
    
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
