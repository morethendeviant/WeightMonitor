//
//  GraphCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 03.05.2023.
//

import UIKit
import Combine
import SwiftUI
import Charts

final class GraphView: UIView {
    
    var onPreviousButtonTapped: () -> Void
    var onNextButtonTapped: () -> Void
    
    private var modelPublisher: AnyPublisher<GraphModel, Never>
    private var graphData: [GraphData] = []
    private var cancellables: Set<AnyCancellable> = []

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        label.text = "Измерения за месяц"
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
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12,
                                                                           weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(nil, action: #selector(previousButtonTapped), for: .touchUpInside)
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
        button.addTarget(nil, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var graph = UIView()

    init(modelPublisher: AnyPublisher<GraphModel, Never> , onPreviousButtonTapped: @escaping () -> Void, onNextButtonTapped: @escaping () -> Void) {
        self.modelPublisher = modelPublisher
        self.onPreviousButtonTapped = onPreviousButtonTapped
        self.onNextButtonTapped = onNextButtonTapped
        
        super.init(frame: .zero)
        
        addSubviews()
        configure()
        applyLayout()
        
        modelPublisher.sink { [weak self] graphModel in
            self?.monthLabel.text = graphModel.monthName
            self?.previousButton.isEnabled = graphModel.isPreviousButtonEnabled
            self?.nextButton.isEnabled = graphModel.isNextButtonEnabled
            self?.previousButton.backgroundColor = graphModel.isPreviousButtonEnabled ? .textElementsTertiary : .generalGray1
            self?.nextButton.backgroundColor = graphModel.isNextButtonEnabled ? .textElementsTertiary : .generalGray1
            self?.graphData = graphModel.graphData
            self?.createContent()
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GraphView {
    @objc func previousButtonTapped() {
        onPreviousButtonTapped()
    }
    
    @objc func nextButtonTapped() {
        onNextButtonTapped()
    }
}

// MARK: - Subviews configure + layout

private extension GraphView {
    func createContent() {
        graph.removeFromSuperview()

        if #available(iOS 16.0, *) {
            let configuration = UIHostingConfiguration(content: {
                if !graphData.isEmpty {
                    Chart(graphData) { point in
                        LineMark(x: .value("", point.date.toString()),
                                 y: .value("", point.value))
                        .symbol(.circle)

                    }
                    .foregroundColor(Color(uiColor: .mainAccent ?? .blue))
                } else {
                    Text("Нет записей")
                }
            })

            graph = configuration.makeContentView()
        }

        addSubview(graph)
        graph.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            graph.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 31),
            graph.leadingAnchor.constraint(equalTo: leadingAnchor),
            graph.bottomAnchor.constraint(equalTo: bottomAnchor),
            graph.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(monthLabel)
        addSubview(previousButton)
        addSubview(nextButton)
    }
    
    func configure() {
        [titleLabel, monthLabel, previousButton, nextButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor, constant: -2),
            
            previousButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -16),
            previousButton.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            previousButton.heightAnchor.constraint(equalToConstant: 24),
            previousButton.widthAnchor.constraint(equalToConstant: 24),
            
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 24),
            nextButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
}
