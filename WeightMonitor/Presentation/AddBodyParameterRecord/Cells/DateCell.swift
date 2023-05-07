//
//  DateCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 06.05.2023.
//

import UIKit
import Combine

final class DateCell: UITableViewCell {
    
    var buttonPressedSubject = PassthroughSubject<Void, Never>()
    
    var buttonTitle = "Сегодня" {
        didSet {
            datePickButton.setTitle(buttonTitle, for: .normal) 
        }
    }
    
    private lazy var dateTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Дата"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var datePickButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        configuration.imagePadding = 15
        
        let image = UIImage(systemName: "chevron.right",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12,
                                                                           weight: .bold))
        
        let button = UIButton(configuration: configuration)
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(.mainAccent, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setImage(image, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .textElementsPrimary
        button.addTarget(nil, action: #selector(buttonTapped), for: .touchUpInside)
        return button
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

private extension DateCell {
    @objc func buttonTapped() {
        buttonPressedSubject.send()
    }
}

// MARK: - Subviews configure + layout
private extension DateCell {
    func addSubviews() {
        contentView.addSubview(dateTextLabel)
        contentView.addSubview(datePickButton)
    }
    
    func configure() {
        [dateTextLabel, datePickButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        backgroundColor = .popUpBg
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            dateTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            datePickButton.centerYAnchor.constraint(equalTo: dateTextLabel.centerYAnchor),
            datePickButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
