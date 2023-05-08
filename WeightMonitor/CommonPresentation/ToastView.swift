//
//  ToastView.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import UIKit

enum ToastStyle {
    case info, error
}

final class ToastView: UIView {

    private var style: ToastStyle?
    private var message: String

    private lazy var alertLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .popUpBg
        label.numberOfLines = 1
        return label
    }()

    init(_ toast: ToastMessage) {
        self.message = toast.message
        self.style = toast.style
        super.init(frame: CGRect.zero)
        addSubviews()
        configure()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ToastView {
    func addSubviews() {
        addSubview(alertLabel)
    }
    
    func configure() {
        var genericText: String
        switch style {
        case .error: genericText = "Что-то пошло не так!"
        case .info: genericText = ""
        default: genericText = ""
        }
        
        alertLabel.text = genericText + message
        backgroundColor = .textElementsPrimary
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            alertLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            alertLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            alertLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
