//
//  WidgetCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit
import Combine

struct WidgetItem: Hashable {
    static func == (lhs: WidgetItem, rhs: WidgetItem) -> Bool {
        lhs.primaryValue == rhs.primaryValue &&
        lhs.secondaryValue == rhs.secondaryValue &&
        lhs.isMetricOn == rhs.isMetricOn
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(primaryValue)
    }
    
    let primaryValue: String
    let secondaryValue: String
    let isMetricOn: Bool
    let metricSwitchPublisher: PassthroughSubject<Bool, Never>
}

final class WidgetCell: UITableViewCell {
    
    var metricSwitchPublisher = PassthroughSubject<Bool, Never>()
    
    var appearanceModel: WidgetAppearance? {
        didSet {
            title.text = appearanceModel?.widgetTitle
            if let imageName = appearanceModel?.imageName {
                cornerImage.image = UIImage(named: imageName)
            }
        }
    }
    
    var model: WidgetItem? {
        didSet {
            parameterLabel.text = model?.primaryValue
            parameterDeltaLabel.text = model?.secondaryValue
            metricSwitch.isOn = model?.isMetricOn ?? false
            if let model {
                metricSwitchPublisher = model.metricSwitchPublisher
            }
        }
    }
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textElementsTertiary
        return label
    }()
    
    private lazy var parameterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var parameterDeltaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textElementsSecondary
        return label
    }()
    
    private lazy var cornerImage = UIImageView()
    
    private lazy var metricSwitch: UISwitch = {
        let control = UISwitch()
        control.onTintColor = .mainAccent
        control.addTarget(nil, action: #selector(selectSwitch), for: .touchUpInside)
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

private extension WidgetCell {
    @objc func selectSwitch() {
        metricSwitch.isOn.toggle()
        metricSwitchPublisher.send(!metricSwitch.isOn)
    }
}

// MARK: - Subviews configure + layout

private extension WidgetCell {
    func addSubviews() {
        contentView.addSubview(title)
        contentView.addSubview(parameterLabel)
        contentView.addSubview(parameterDeltaLabel)
        contentView.addSubview(cornerImage)
        contentView.addSubview(metricSwitch)
        contentView.addSubview(metricLabel)
    }
    
    func configure() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = .generalGray1
        
        [title, parameterLabel, parameterDeltaLabel, cornerImage, metricSwitch, metricLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    // TODO: Replace magic numbers
    func applyLayout() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            parameterLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            parameterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            parameterDeltaLabel.leadingAnchor.constraint(equalTo: parameterLabel.trailingAnchor, constant: 8),
            parameterDeltaLabel.bottomAnchor.constraint(equalTo: parameterLabel.bottomAnchor),
            
            metricSwitch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            metricSwitch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            metricLabel.leadingAnchor.constraint(equalTo: metricSwitch.trailingAnchor, constant: 16),
            metricLabel.centerYAnchor.constraint(equalTo: metricSwitch.centerYAnchor),
            
            cornerImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            cornerImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cornerImage.heightAnchor.constraint(equalToConstant: 69),
            cornerImage.widthAnchor.constraint(equalToConstant: 106)
        ])
    }
}
