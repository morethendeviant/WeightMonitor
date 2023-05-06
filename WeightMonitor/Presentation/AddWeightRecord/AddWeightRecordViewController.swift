//
//  AddWeightRecordViewController.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 05.05.2023.
//

import UIKit
import Combine

final class AddWeightRecordViewController: UIViewController {

    private var cancellables: Set<AnyCancellable> = []
    
    private var datePickerIsShown: Bool = false {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавить вес"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var tabBarIcon: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.backgroundColor = .tabBarIcon
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.isScrollEnabled = false
        //table.separatorColor = .generalGray1
        return table
    }()
    
    private lazy var createRecordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = .mainAccent
        button.setTitle("Добавить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.tintColor = .white
        //button.addTarget(nil, action: #selector(), for: .touchUpInside)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        addSubviews()
        configure()
        applyLayout()
        //setUpBindings()
    }
}

extension AddWeightRecordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = DateCell()
            cell.selectionStyle = .none
            cell.buttonPressedSubject
                .sink { [weak self] _ in
                    self?.datePickerIsShown = true
                }
                .store(in: &cancellables)
            return cell
        case 1:
            let cell = DatePickerCell()
            cell.selectionStyle = .none
            cell.date
                .sink { date in
                    if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DateCell {
                        let dateText = date.onlyDate() == Date().onlyDate() ? "Сегодня   " : date.toString()
                        cell.buttonTitle = dateText
                    }                    
                }
                .store(in: &cancellables)
            return cell
        case 2:
            let cell = WeightCell()
            cell.selectionStyle = .none

            cell.weightTextFieldIsBeingEditing
                .sink { [weak self] _ in
                    self?.datePickerIsShown = false
                }
                .store(in: &cancellables)
            return cell
        default: return UITableViewCell()
        }
    }
}

extension AddWeightRecordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 54
        case 1: return datePickerIsShown ? 216 : 0
        case 2: return 72
        default: return 0
        }
    }
}

private extension AddWeightRecordViewController {
    func setUpBindings() {

    }
}

// MARK: - Subviews configure + layout
private extension AddWeightRecordViewController {
    func addSubviews() {
        view.addSubview(tabBarIcon)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(createRecordButton)
    }
    
    func configure() {
        view.backgroundColor = .generalBg

        [titleLabel, tabBarIcon, tableView, createRecordButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            tabBarIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tabBarIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tabBarIcon.widthAnchor.constraint(equalToConstant: 36),
            tabBarIcon.heightAnchor.constraint(equalToConstant: 5),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 400),
            
            createRecordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createRecordButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
            createRecordButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            createRecordButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            createRecordButton.heightAnchor.constraint(equalToConstant: 48)


            
            
        ])
    }
}

//override func viewDidLoad() {
//    super.viewDidLoad()
//
//}


