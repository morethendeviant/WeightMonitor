//
//  WidgetCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit
import Combine

final class WidgetView: UIView {
    
    private var modelPublisher: AnyPublisher<WidgetModel, Never>
    
    private var onMetricSwitchTapped: (Bool) -> Void
    private var cancellables: Set<AnyCancellable> = []

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
    
    init(appearanceModel: WidgetAppearance, modelPublisher: AnyPublisher<WidgetModel, Never>, onMetricSwitchTapped: @escaping (Bool) -> Void) {
        self.modelPublisher = modelPublisher
        self.onMetricSwitchTapped = onMetricSwitchTapped

        super.init(frame: .zero)
        
        title.text = appearanceModel.widgetTitle
        cornerImage.image = UIImage(named: appearanceModel.imageName)
          
        addSubviews()
        configure()
        applyLayout()
        
        modelPublisher.sink(receiveValue: { [weak self] widgetModel in
            self?.parameterLabel.text = widgetModel.primaryValue
            self?.parameterDeltaLabel.text = widgetModel.secondaryValue
            self?.metricSwitch.isOn = widgetModel.isMetricOn
        })
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension WidgetView {
    @objc func selectSwitch() {
        metricSwitch.setOn(!metricSwitch.isOn, animated: false)
        onMetricSwitchTapped(!metricSwitch.isOn)
    }
}

// MARK: - Subviews configure + layout

private extension WidgetView {
    func addSubviews() {
        addSubview(title)
        addSubview(parameterLabel)
        addSubview(parameterDeltaLabel)
        addSubview(cornerImage)
        addSubview(metricSwitch)
        addSubview(metricLabel)
    }
    
    func configure() {
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = .generalGray1
        
        [title, parameterLabel, parameterDeltaLabel, cornerImage, metricSwitch, metricLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
        
    func applyLayout() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            parameterLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            parameterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            parameterDeltaLabel.leadingAnchor.constraint(equalTo: parameterLabel.trailingAnchor, constant: 8),
            parameterDeltaLabel.bottomAnchor.constraint(equalTo: parameterLabel.bottomAnchor),
            
            metricSwitch.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            metricSwitch.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            metricLabel.leadingAnchor.constraint(equalTo: metricSwitch.trailingAnchor, constant: 16),
            metricLabel.centerYAnchor.constraint(equalTo: metricSwitch.centerYAnchor),
            
            cornerImage.topAnchor.constraint(equalTo: topAnchor),
            cornerImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            cornerImage.heightAnchor.constraint(equalToConstant: 69),
            cornerImage.widthAnchor.constraint(equalToConstant: 106)
        ])
    }
}

//{
//   didSet {
//       if let model {
//
//       }
//   }
//}
