//
//  AddWeightRecordViewController.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 05.05.2023.
//

import UIKit
import Combine

final class BodyParameterRecordViewController: UIViewController {
    
    private var viewModel: BodyParameterRecordViewModelProtocol
    
    private var contentModel: RecordModuleModel
    private var cancellables: Set<AnyCancellable> = []
    private var datePickerHeight: CGFloat = 0
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
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
        table.backgroundColor = .clear
        table.isScrollEnabled = false
        table.allowsSelection = false
        return table
    }()
    
    private lazy var createRecordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = .mainAccent
        button.setTitle(contentModel
            .bodyParameterAppearance
            .confirmButtonName, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.tintColor = .white
        button.addTarget(nil, action: #selector(createRecordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var createRecordButtonBottomConstraint = NSLayoutConstraint()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hideKeyboardWhenTappedAround()
        addSubviews()
        configure()
        applyLayout()
        setSubscriptions()
        setObservers()
        viewModel.viewDidLoad()
    }
    
    init(viewModel: BodyParameterRecordViewModelProtocol, contentModel: RecordModuleModel) {
        self.viewModel = viewModel
        self.contentModel = contentModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - TableView Data Source

extension BodyParameterRecordViewController: UITableViewDataSource {
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
            
            cell.datePublisher.sink { [weak self] date in
                self?.viewModel.date.send(date)
            }
            .store(in: &cancellables)
            
            viewModel.date
                .eraseToAnyPublisher()
                .assign(to: \.date, on: cell)
                .store(in: &cancellables)
            
            return cell
            
        case 2:
            let cell = BodyParameterValueCell()
            cell.bodyParameterTextFieldIsBeingEditing
                .sink { [weak self] in
                    self?.viewModel.parameterTextFieldIsBeingEditing()
                }
                .store(in: &cancellables)
            
            cell.textPublisher?.sink { [weak self] parameter in
                self?.viewModel.parameter.send(parameter)
            }
            .store(in: &cancellables)
            
            viewModel.unitsName
                .eraseToAnyPublisher()
                .assign(to: \.unitsName, on: cell)
                .store(in: &cancellables)
            
            viewModel.parameter
                .eraseToAnyPublisher()
                .assign(to: \.value, on: cell)
                .store(in: &cancellables)
            
            cell.appearanceModel = contentModel.bodyParameterAppearance
            return cell
        default: return UITableViewCell()
        }
    }
}

// MARK: - TableView Delegate

extension BodyParameterRecordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 54
        case 1: return datePickerHeight
        case 2: return 72
        default: return 0
        }
    }
}

// MARK: - Private Methods

private extension BodyParameterRecordViewController {
    func setSubscriptions() {
        viewModel.showDatePicker.sink { [weak self] state in
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
        
        viewModel.isConfirmButtonEnabled.sink { [weak self] state in
            self?.createRecordButton.isEnabled = state
            self?.createRecordButton.backgroundColor = state ? .mainAccent : .mainAccent?.withAlphaComponent(0.5)
        }
        .store(in: &cancellables)
    }
    
    @objc func createRecordButtonTapped() {
        viewModel.confirmButtonTapped()
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification,
                             viewBottomConstraint: createRecordButtonBottomConstraint,
                             keyboardWillShow: true)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification,
                             viewBottomConstraint: createRecordButtonBottomConstraint,
                             keyboardWillShow: false)
    }
    
    func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        
        let keyboardHeight = keyboardSize.height
        
        guard let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {
            return
        }
        
        guard let rawValue = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let keyboardCurve = UIView.AnimationCurve(rawValue: rawValue)
        else {
            return
        }
        
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
            let bottomConstant: CGFloat = -16
            viewBottomConstraint.constant = -keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
        } else {
            viewBottomConstraint.constant = -16
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
}

// MARK: - Subviews configure + layout

private extension BodyParameterRecordViewController {
    func addSubviews() {
        view.addSubview(tabBarIcon)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(createRecordButton)
    }
    
    func configure() {
        view.backgroundColor = .popUpBg
        [titleLabel, tabBarIcon, tableView, createRecordButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        titleLabel.text = contentModel.screenTitle
    }
    
    func applyLayout() {
        createRecordButtonBottomConstraint = NSLayoutConstraint(item: createRecordButton,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: view.safeAreaLayoutGuide,
                                                          attribute: .bottom,
                                                          multiplier: 1,
                                                          constant: -16)
        createRecordButtonBottomConstraint.isActive = true

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
            createRecordButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            createRecordButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            createRecordButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
