//
//  ViewController.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit
import Combine

final class BodyParameterControlViewController: UIViewController {
    
    private var viewModel: BodyParameterControlViewModelProtocol
    private var contentModel: ModuleModel
    private lazy var dataSource = BodyParameterControlDataSource(tableView)
    private var cancellables: Set<AnyCancellable> = []

    private var historyHeaderModel: HistorySectionHeaderModel?
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(WidgetCell.self, forCellReuseIdentifier: WidgetCell.identifier)
        table.register(GraphCell.self, forCellReuseIdentifier: GraphCell.identifier)
        table.register(HistoryTableCell.self, forCellReuseIdentifier: HistoryTableCell.identifier)
        table.register(HistorySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: HistorySectionHeaderView.identifier)
        table.register(GraphSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: GraphSectionHeaderView.identifier)
        table.allowsSelection = false
        table.separatorStyle = .none
        table.delegate = self
        return table
    }()
    
    private lazy var addRecordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 24
        button.backgroundColor = .mainAccent
        let image = UIImage(systemName: "plus",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18,
                                                                           weight: .bold))
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(nil, action: #selector(addRecordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubscriptions()
        addSubviews()
        configure()
        applyLayout()
        viewModel.viewDidLoad()
    }
    
    init(viewModel: BodyParameterControlViewModelProtocol, contentModel: ModuleModel) {
        self.viewModel = viewModel
        self.contentModel = contentModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BodyParameterControlViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 129
        case 1: return 281
        case 2: return 46
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1: return 64
        case 2: return 67
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 2: return 115
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let model = GraphSectionHeaderModel(monthName: "Май",
                                                isPreviousButtonEnabled: true,
                                                isNextButtonEnabled: false)
            let header = GraphSectionHeaderView()
            header.model = model
            return header
        case 2:
            let header = HistorySectionHeaderView()
            if let historyHeaderModel {
                header.model = historyHeaderModel
            }
            
            return header
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 2 else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, complete in
            guard let cell = tableView.cellForRow(at: indexPath) as? HistoryTableCell,
                  let id = cell.model?.id else { return }
            
            self?.viewModel.deleteRecord(id: id)
            complete(true)
        }
        
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Private Methods

private extension BodyParameterControlViewController {
    func setUpSubscriptions() {
        viewModel.sectionDataPublisher
            .sink { [weak self] sectionsData in
                self?.dataSource.reload(sectionsData)
            }
            .store(in: &cancellables)
    }
    
    @objc func addRecordButtonTapped() {
        viewModel.addRecordButtonTapped()
    }
}

// MARK: - Subviews configure + layout

private extension BodyParameterControlViewController {
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(addRecordButton)
    }
    
    func configure() {
        navigationItem.titleView = titleLabel
        view.backgroundColor = .generalBg
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        
        [tableView, addRecordButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        historyHeaderModel = contentModel.historyHeader
        titleLabel.text = contentModel.mainScreenTitle
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            addRecordButton.heightAnchor.constraint(equalToConstant: 48),
            addRecordButton.widthAnchor.constraint(equalToConstant: 48),
            addRecordButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addRecordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)

        ])
    }
}