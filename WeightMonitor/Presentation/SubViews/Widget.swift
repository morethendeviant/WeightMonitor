//
//  Widget.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit

final class Widget: UIView {
    
    var weight: Double = 0 {
        didSet {
            weightLabel.text = String(format: "%.1f кг", weight)
        }
    }
    
    var weightDelta: Double = 0 {
        didSet {
            weightDeltaLabel.text = String(format: "%.1f кг", weightDelta)
        }
    }
    
    var metricIsOn: Bool = false {
        didSet {
            metricSwitch.isOn = metricIsOn
        }
    }
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = "Текущий вес"
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configure()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Subviews configure + layout
private extension Widget {
    func addSubviews() {
        addSubview(title)
        addSubview(weightLabel)
        addSubview(weightDeltaLabel)
        addSubview(scales)
        addSubview(metricSwitch)
        addSubview(metricLabel)
    }
    
    func configure() {
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = .generalGray1
        [title, weightLabel, weightDeltaLabel, scales, metricSwitch, metricLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    // TODO: Replace magic numbers
    func applyLayout() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            weightLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            weightLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            weightDeltaLabel.leadingAnchor.constraint(equalTo: weightLabel.trailingAnchor, constant: 8),
            weightDeltaLabel.bottomAnchor.constraint(equalTo: weightLabel.bottomAnchor),
            
            metricSwitch.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 16),
            metricSwitch.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            metricLabel.leadingAnchor.constraint(equalTo: metricSwitch.trailingAnchor, constant: 16),
            metricLabel.centerYAnchor.constraint(equalTo: metricSwitch.centerYAnchor),
            
            scales.topAnchor.constraint(equalTo: self.topAnchor),
            scales.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scales.heightAnchor.constraint(equalToConstant: 69),
            scales.widthAnchor.constraint(equalToConstant: 106)
        ])
    }
}

