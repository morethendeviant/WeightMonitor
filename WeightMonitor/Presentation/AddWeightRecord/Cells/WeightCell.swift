//
//  WeightCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 06.05.2023.
//

import UIKit
import Combine

final class WeightCell: UITableViewCell {

    var weightTextFieldIsBeingEditing = PassthroughSubject<Void, Never>()

    private lazy var weightTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Вес"
        textField.font = .boldSystemFont(ofSize: 34)
        textField.textColor = .textElementsPrimary
        textField.delegate = self
        textField.keyboardType = .decimalPad

        return textField
    }()
    
    private lazy var unitsLabel: UILabel = {
        let label = UILabel()
        label.text = "кг"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textElementsTertiary
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

extension WeightCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        weightTextFieldIsBeingEditing.send()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.textLimit(existingText: textField.text, newText: string, limit: 5)
    }
    
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        if newText.isEmpty { return true }
        
        if newText == "," {
            return !text.contains(",") && !text.isEmpty
        } else {
            let components = text.components(separatedBy: ",")
            let wholePart = components.first ?? ""
            let fractionalPart = components.last ?? ""
            
            switch components.count {
            case 1: return wholePart.count < 3
            case 2: return fractionalPart.count < 1
            default: return true
            }
        }
    }
}


// MARK: - Subviews configure + layout
private extension WeightCell {
    func addSubviews() {
        contentView.addSubview(weightTextField)
        contentView.addSubview(unitsLabel)
    }
    
    func configure() {
        [weightTextField, unitsLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            weightTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            weightTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weightTextField.trailingAnchor.constraint(equalTo: unitsLabel.leadingAnchor, constant:  -4),

            
            unitsLabel.centerYAnchor.constraint(equalTo: weightTextField.centerYAnchor),
            unitsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
