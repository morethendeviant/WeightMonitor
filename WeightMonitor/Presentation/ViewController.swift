//
//  ViewController.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit

class ViewController: UIViewController {
    let widget = Widget()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Монитор веса"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleLabel
        view.backgroundColor = .generalBg
        
        addSubviews()
        configure()
        applyLayout()
        
        widget.weight = 83.5
        widget.weightDelta = -0.5
        view.addSubview(widget)
    }
}


// MARK: - Subviews configure + layout
private extension ViewController {
    func addSubviews() {
        view.addSubview(widget)
    }
    
    func configure() {
        widget.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            widget.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            widget.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            widget.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            widget.heightAnchor.constraint(equalToConstant: 129)
        ])
    }
}
