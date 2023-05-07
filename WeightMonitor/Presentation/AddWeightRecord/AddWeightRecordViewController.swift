//
//  AddWeightRecordViewController.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 05.05.2023.
//

import UIKit
import Combine

final class AddWeightRecordViewController: UIViewController {
    
    var viewModel: AddWeightRecordViewModelProtocol

    private var cancellables: Set<AnyCancellable> = []
    private var datePickerHeight: CGFloat = 0
    
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
        table.allowsSelection = false
        return table
    }()
    
    private lazy var createRecordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = .mainAccent
        button.setTitle("Добавить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.tintColor = .white
        button.addTarget(nil, action: #selector(createRecordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hideKeyboardWhenTappedAround()
        addSubviews()
        configure()
        applyLayout()
        setSubscriptions()
    }
    
    init(viewModel: AddWeightRecordViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - TableView Data Source

extension AddWeightRecordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = DateCell()
            cell.buttonPressedSubject
                .sink { [weak self] in
                    self?.viewModel.dateButtonTapped()
                }
                .store(in: &cancellables)
            
            viewModel.dateButtonLabel
                .eraseToAnyPublisher()
                .assign(to: \.buttonTitle, on: cell)
                .store(in: &cancellables)
            return cell
        case 1:
            let cell = DatePickerCell()
            
            cell.$date.sink { [weak self] date in
                self?.viewModel.date.send(date)
            }
            .store(in: &cancellables)
            
            return cell
        case 2:
            let cell = WeightCell()
            cell.weightTextFieldIsBeingEditing
                .sink { [weak self] in
                    self?.viewModel.weightTextFieldIsBeingEditing()
                }
                .store(in: &cancellables)
            
            cell.textPublisher?.sink { [weak self] weight in
                self?.viewModel.weight.send(weight)
            }
            .store(in: &cancellables)
            
            return cell
        default: return UITableViewCell()
        }
    }
}

// MARK: - TableView Delegate

extension AddWeightRecordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 54
        case 1: return datePickerHeight
        case 2: return 72
        default: return 0
        }
    }
}

private extension AddWeightRecordViewController {
    func setSubscriptions() {
        viewModel.showDatePicker.sink { [weak self] state in
            print(state)

            guard let self else { return }
            if state {
                self.view.endEditing(false)
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DatePickerCell {
                cell.isHidden = !state
            }
            
            self.tableView.beginUpdates()
            datePickerHeight = state ? 216 : 0
            self.tableView.endUpdates()
        }
        .store(in: &cancellables)
        
        viewModel.isCreateButtonEnabled.sink { [weak self] state in
            self?.createRecordButton.isEnabled = state
            self?.createRecordButton.backgroundColor = state ? .mainAccent : .mainAccent?.withAlphaComponent(0.5)
        }
        .store(in: &cancellables)
    }
    
    @objc func createRecordButtonTapped() {
        viewModel.createButtonTapped()
        dismiss(animated: true)
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
        [titleLabel, tabBarIcon, tableView, createRecordButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
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
