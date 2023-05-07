//
//  WidgetCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit

struct WidgetItem: Hashable {
    let widgetTitle: String
    let primaryValue: String
    let secondaryValue: String
    let isMetricOn: Bool
    //var onMetricSet: (() -> Void)?
}

final class WidgetCell: UITableViewCell {
    static let identifier = "WidgetCell"
    
    var model: WidgetItem? {
        didSet {
            title.text = model?.widgetTitle
            weightLabel.text = model?.primaryValue
            weightDeltaLabel.text = model?.secondaryValue
            metricSwitch.isOn = model?.isMetricOn ?? false
        }
    }
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textElementsTertiary
        return label
    }()
    
    private lazy var weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var weightDeltaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textElementsSecondary
        return label
    }()
    
    private lazy var scales: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "scales")
        return imageView
    }()
    
    private lazy var metricSwitch: UISwitch = {
        let control = UISwitch()
        control.onTintColor = .mainAccent
        return control
    }()
    
    private lazy var metricLabel: UILabel = {
        let label = UILabel()
        label.text = "Метрическая система"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textElementsPrimary
        return label
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

private extension WidgetCell {
    func addSubviews() {
        contentView.addSubview(title)
        contentView.addSubview(weightLabel)
        contentView.addSubview(weightDeltaLabel)
        contentView.addSubview(scales)
        contentView.addSubview(metricSwitch)
        contentView.addSubview(metricLabel)
    }
    
    func configure() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = .generalGray1
        
        [title, weightLabel, weightDeltaLabel, scales, metricSwitch, metricLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    // TODO: Replace magic numbers
    func applyLayout() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            weightLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            weightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            weightDeltaLabel.leadingAnchor.constraint(equalTo: weightLabel.trailingAnchor, constant: 8),
            weightDeltaLabel.bottomAnchor.constraint(equalTo: weightLabel.bottomAnchor),
            
            metricSwitch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            metricSwitch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            metricLabel.leadingAnchor.constraint(equalTo: metricSwitch.trailingAnchor, constant: 16),
            metricLabel.centerYAnchor.constraint(equalTo: metricSwitch.centerYAnchor),
            
            scales.topAnchor.constraint(equalTo: contentView.topAnchor),
            scales.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scales.heightAnchor.constraint(equalToConstant: 69),
            scales.widthAnchor.constraint(equalToConstant: 106)
        ])
    }
}
