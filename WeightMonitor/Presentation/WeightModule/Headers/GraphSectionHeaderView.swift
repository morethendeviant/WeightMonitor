//
//  GraphSectionHeaderView.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import UIKit

final class GraphSectionHeaderView: UITableViewHeaderFooterView {
    static let identifier: String = "GraphSectionHeaderView"

    var model: GraphSectionHeaderModel? {
        didSet {
            monthLabel.text = model?.monthName
            previousButton.backgroundColor = .textElementsTertiary
            nextButton.backgroundColor = .textElementsTertiary
        }
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Измерения за месяц"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        return label
    }()

    private var monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .textElementsSecondary
        return label
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        let image = UIImage(systemName: "chevron.left",
                            withConfiguration: UIImage.SymbolConfiguration (pointSize: 12, weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        
        let image = UIImage(systemName: "chevron.right",
                            withConfiguration: UIImage.SymbolConfiguration (pointSize: 12, weight: .semibold))
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    init() {
        super.init(reuseIdentifier: HistorySectionHeaderView.identifier)
        addSubviews()
        configure()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews configure + layout

private extension GraphSectionHeaderView {
    func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(monthLabel)
        contentView.addSubview(previousButton)
        contentView.addSubview(nextButton)
    }
    
    func configure() {
        [titleLabel, monthLabel, previousButton, nextButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            monthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor, constant: -2),

            previousButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -16),
            previousButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            previousButton.heightAnchor.constraint(equalToConstant: 24),
            previousButton.widthAnchor.constraint(equalToConstant: 24),

            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 24),
            nextButton.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
}
