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

final class GraphCell: UITableViewCell {
    
    var previousButtonPublisher = PassthroughSubject<Void, Never>()
    var nextButtonPublisher = PassthroughSubject<Void, Never>()

    var model: GraphItem? {
        didSet {
            if let model {
                monthLabel.text = model.monthName
                previousButton.isEnabled = model.isPreviousButtonEnabled
                nextButton.isEnabled = model.isNextButtonEnabled
                previousButton.backgroundColor = model.isPreviousButtonEnabled ? .textElementsTertiary : .generalGray1
                nextButton.backgroundColor = model.isNextButtonEnabled ? .textElementsTertiary : .generalGray1
                graphData = model.graphData
                previousButtonPublisher = model.previousButtonPublisher
                nextButtonPublisher = model.nextButtonPublisher
            }
        }
    }
    
    var graphData: [GraphData] = [] {
        didSet {
            createContent()
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

private extension GraphCell{
    @objc func previousButtonTapped() {
        previousButtonPublisher.send()
    }
    
    @objc func nextButtonTapped() {
        nextButtonPublisher.send()
    }
}

// MARK: - Subviews configure + layout

private extension GraphCell {
    func createContent() {

        let config = UIHostingConfiguration(content: {
            Chart(graphData) { point in
                LineMark(x: .value("Дата", point.date.toString()),
                         y: .value("Вес", point.value))
                .symbol(.circle)
                
            }
            .foregroundColor(Color(uiColor: .mainAccent ?? .blue))
            
        })
        graph.removeFromSuperview()
        graph = config.makeContentView()
        contentView.addSubview(graph)

        graph.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            graph.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 31),
            graph.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            graph.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            graph.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func addSubviews() {
        contentView.addSubview(monthLabel)
        contentView.addSubview(previousButton)
        contentView.addSubview(nextButton)
    }
    
    func configure() {
        [monthLabel, previousButton, nextButton]
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
        ])
    }
}
