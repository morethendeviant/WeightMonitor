//
//  ViewController.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit
import Combine

final class BodyParameterControlViewController: UIViewController, AlertPresentable {
    
    private var viewModel: BodyParameterControlViewModelProtocol
    private var contentModel: ParameterControlModuleModel
    private lazy var dataSource = BodyParameterControlDataSource(tableView,
                                                                 widgetAppearance: contentModel.widgetAppearance)
    private var cancellables: Set<AnyCancellable> = []
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(HistoryTableCell.self, forCellReuseIdentifier: HistoryTableCell.identifier)
        table.allowsSelection = false
        table.separatorStyle = .none
        let footerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                        size: CGSize(width: 0, height: 115)))
        table.tableFooterView = footerView
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
    
    init(viewModel: BodyParameterControlViewModelProtocol, contentModel: ParameterControlModuleModel) {
        self.viewModel = viewModel
        self.contentModel = contentModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Table View Delegate

extension BodyParameterControlViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 129
        case 1: return 336
        case 2: return 46
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1: return 40
        case 2: return 67
        default: return 0
        }
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let header = GraphSectionHeaderView()
            header.appearanceModel = contentModel.graphHeaderAppearance
            return header
        case 2:
            let header = HistorySectionHeaderView()
            header.appearanceModel = contentModel.historyHeaderAppearance
            return header
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 2 else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "") { [weak self] _, _, complete in
            guard let cell = tableView.cellForRow(at: indexPath) as? HistoryTableCell,
                  let id = cell.model?.id else { return }
            
            self?.viewModel.deleteRecord(id: id)
            complete(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "") { [weak self] _, _, complete in
            guard let cell = tableView.cellForRow(at: indexPath) as? HistoryTableCell,
                  let id = cell.model?.id else { return }
            
            self?.viewModel.editRecord(id: id)
            complete(true)
        }
        
        editAction.image = UIImage(systemName: "square.and.pencil")
        editAction.backgroundColor = .mainAccent
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
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
        titleLabel.text = contentModel.screenTitle
        
        [tableView, addRecordButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
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
