//
//  WeightCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 06.05.2023.
//

import UIKit
import Combine

final class BodyParameterValueCell: UITableViewCell {

    var bodyParameterTextFieldIsBeingEditing: () -> Void
    var unitsName: String = "" {
        didSet {
            unitsLabel.text = unitsName
        }
    }
    
    var value: String = "" {
        didSet {
            bodyParameterTextField.text = value
        }
    }
    
    var textPublisher: AnyPublisher<String, Never>?
    var appearanceModel: BodyParameterAppearance? {
        didSet {
            bodyParameterTextField.placeholder = appearanceModel?.parameterName
        }
    }
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? ""
    }
    
    private lazy var bodyParameterTextField: UITextField = {
        let textField = UITextField()
        textField.font = .boldSystemFont(ofSize: 34)
        textField.textColor = .textElementsPrimary
        textField.keyboardType = .decimalPad
        textField.delegate = self
        return textField
    }()
    
    private lazy var unitsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textElementsTertiary
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    init(bodyParameterTextFieldIsBeingEditing: @escaping () -> Void) {
        self.bodyParameterTextFieldIsBeingEditing = bodyParameterTextFieldIsBeingEditing
        super.init(style: .default, reuseIdentifier: nil)
        addSubviews()
        configure()
        applyLayout()
        textPublisher = bodyParameterTextField.textPublisher
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BodyParameterValueCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        bodyParameterTextFieldIsBeingEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.textLimit(existingText: textField.text, newText: string, limit: 5)
    }
    
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        if newText.isEmpty { return true }
        
        if newText == decimalSeparator {
            return !text.contains(decimalSeparator) && !text.isEmpty
        }
        
        if newText.isNumber {
            let components = text.components(separatedBy: decimalSeparator)
            let wholePart = components.first ?? ""
            let fractionalPart = components.last ?? ""
            
            switch components.count {
            case 1: return wholePart.count < 3
            case 2: return fractionalPart.count < 1
            default: return true
            }
        }
        
        return false
    }
}

// MARK: - Subviews configure + layout

private extension BodyParameterValueCell {
    func addSubviews() {
        contentView.addSubview(bodyParameterTextField)
        contentView.addSubview(unitsLabel)
    }
    
    func configure() {
        backgroundColor = .popUpBg
        [bodyParameterTextField, unitsLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            bodyParameterTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bodyParameterTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bodyParameterTextField.trailingAnchor.constraint(equalTo: unitsLabel.leadingAnchor, constant: -4),

            unitsLabel.centerYAnchor.constraint(equalTo: bodyParameterTextField.centerYAnchor),
            unitsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
