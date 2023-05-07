//
//  GraphCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 03.05.2023.
//

import UIKit

struct GraphItem: Hashable {
    let monthName: String
    let isPreviousButtonEnabled: Bool
    let isNextButtonEnabled: Bool
    let graphData: [GraphData]
}

struct GraphData: Hashable {
    let value: Double
    let date: Date
}

final class GraphCell: UITableViewCell {
    static let identifier = "GraphCell"
    
    var model: GraphItem? {
        didSet {
            if let model {
                monthLabel.text = model.monthName
                previousButton.backgroundColor = model.isPreviousButtonEnabled ? .textElementsTertiary : .generalGray1
                nextButton.backgroundColor = model.isNextButtonEnabled ? .textElementsTertiary : .generalGray1
            }
        }
    }
    
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
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12,
                                                                           weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        let image = UIImage(systemName: "chevron.right",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12,
                                                                           weight: .semibold))
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var graphPlaceholder: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .generalGray1
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
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
private extension GraphCell {
    func addSubviews() {
        contentView.addSubview(monthLabel)
        contentView.addSubview(previousButton)
        contentView.addSubview(nextButton)
        contentView.addSubview(graphPlaceholder)
    }
    
    func configure() {
        [monthLabel, previousButton, nextButton, graphPlaceholder]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            monthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor, constant: -2),

            previousButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -16),
            previousButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            previousButton.heightAnchor.constraint(equalToConstant: 24),
            previousButton.widthAnchor.constraint(equalToConstant: 24),

            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 24),
            nextButton.widthAnchor.constraint(equalToConstant: 24),
            
            graphPlaceholder.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 31),
            graphPlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            graphPlaceholder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            graphPlaceholder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
