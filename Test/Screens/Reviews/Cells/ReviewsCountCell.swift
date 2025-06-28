import UIKit

struct ReviewsCountCellConfig {
    static let reuseId = String(describing: ReviewsCountCellConfig.self)
    
    let id = UUID()
    let count: Int
    let textColor: UIColor
    let font: UIFont

}

extension ReviewsCountCellConfig: TableCellConfig {
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewsCountCell else { return }
        cell.update(with: self)
    }
    
    func height(with size: CGSize) -> CGFloat {
        44 // Стандартная высота ячейки
    }
}


final class ReviewsCountCell: UITableViewCell {
    fileprivate var config: Config?
    
    fileprivate let countLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
}

extension ReviewsCountCell {
    fileprivate func setupView() {
        contentView.addSubview(countLabel)
        countLabel.textAlignment = .center
    }
    
    fileprivate func update(with config: ReviewsCountCellConfig) {
        self.config = config
        countLabel.text = "\(config.count) отзывов"
        countLabel.textColor = config.textColor
        countLabel.font = config.font
        countLabel.sizeToFit()
        setupLayout()
    }
    
    private func setupLayout() {
        let labelSize = countLabel.sizeThatFits(contentView.bounds.size)
        countLabel.frame = CGRect(
            x: (contentView.bounds.width - labelSize.width) / 2,
            y: (contentView.bounds.height - labelSize.height) / 2,
            width: labelSize.width,
            height: labelSize.height
        )
    }
}

fileprivate typealias Config = ReviewsCountCellConfig
