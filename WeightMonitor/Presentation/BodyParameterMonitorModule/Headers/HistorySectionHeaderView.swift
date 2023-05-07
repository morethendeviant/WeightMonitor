//
//  HistorySectionHeaderView.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 03.05.2023.
//

import UIKit

final class HistorySectionHeaderView: UITableViewHeaderFooterView {
    static let identifier: String = "HistorySectionHeaderView"
    
    var appearanceModel: HistorySectionHeaderAppearance? {
        didSet {
            titleLabel.text = appearanceModel?.headerTitle
            primaryColumnLabel.text = appearanceModel?.primaryColumnTitle
            secondaryColumnLabel.text = appearanceModel?.secondaryColumnTitle
            tertiaryColumnLabel.text = appearanceModel?.tertiaryColumnTitle
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var primaryColumnLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textElementsTertiary
        return label
    }()
    
    private lazy var secondaryColumnLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textElementsTertiary
        return label
    }()
    
    private lazy var tertiaryColumnLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textElementsTertiary
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
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

private extension HistorySectionHeaderView {
    func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(primaryColumnLabel)
        contentView.addSubview(secondaryColumnLabel)
        contentView.addSubview(tertiaryColumnLabel)
        contentView.addSubview(separatorView)
    }
    
    func configure() {
        [titleLabel, primaryColumnLabel, secondaryColumnLabel, tertiaryColumnLabel, separatorView]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            primaryColumnLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            primaryColumnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            secondaryColumnLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            secondaryColumnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 124),
            
            tertiaryColumnLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            tertiaryColumnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 248),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
