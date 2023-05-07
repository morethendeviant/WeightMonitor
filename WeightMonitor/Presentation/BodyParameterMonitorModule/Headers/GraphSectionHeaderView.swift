//
//  GraphSectionHeaderView.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import UIKit

final class GraphSectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "GraphSectionHeaderView"
    
    var appearanceModel: GraphSectionHeaderAppearance? {
        didSet {
            titleLabel.text = appearanceModel?.headerTitle
        }
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        return label
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
    }
    
    func configure() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
    }
}
