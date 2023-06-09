//
//  HistoryTableCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 03.05.2023.
//

import UIKit

final class HistoryTableCell: UITableViewCell {
    static let identifier = "HistoryTableCell"
    
    var model: TableItemModel? {
        didSet {
            valueLabel.text = model?.value
            valueDeltaLabel.text = model?.valueDelta
            dateLabel.text = model?.date
        }
    }
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var valueDeltaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textElementsSecondary
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .textElementsTertiary
        return label
    }()
    
    private lazy var disclosureIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 12,
                                                                                 weight: .semibold))
        imageView.tintColor = .textElementsPrimary
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        configure()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews configure + layout

private extension HistoryTableCell {
    func addSubviews() {
        contentView.addSubview(valueLabel)
        contentView.addSubview(valueDeltaLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(disclosureIndicator)
    }
    
    func configure() {
        [valueLabel, valueDeltaLabel, dateLabel, disclosureIndicator]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            valueDeltaLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueDeltaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 124),
            
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 248),
            
            disclosureIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23)
        ])
    }
}
