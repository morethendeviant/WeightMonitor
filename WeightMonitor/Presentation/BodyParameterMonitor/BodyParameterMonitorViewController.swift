//
//  ViewController.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit
import Combine

final class BodyParameterMonitorViewController: UIViewController, ToastPresentable {
    
    private var viewModel: BodyParameterMonitorViewModelProtocol
    private var contentModel: ParameterControlModuleModel
    private lazy var dataSource = BodyParameterMonitorDataSource(tableView,
                                                                 widgetAppearance: contentModel.widgetAppearance)
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .textElementsPrimary
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var widgetView = WidgetView(appearanceModel: contentModel.widgetAppearance,
                                             modelPublisher: viewModel.widgetDataPublisher.eraseToAnyPublisher(),
                                             onMetricSwitchTapped: viewModel.toggleMetricSwitchTo)
    
    private lazy var graphView = GraphView(modelPublisher: viewModel.graphDataPublisher.eraseToAnyPublisher(),
                                           onPreviousButtonTapped: viewModel.previousMonthButtonTapped,
                                           onNextButtonTapped: viewModel.nextMonthButtonTapped)
    
    private lazy var tableView: IntrinsicTableView = {
        let table = IntrinsicTableView()
        table.register(HistoryTableCell.self, forCellReuseIdentifier: HistoryTableCell.identifier)
        table.allowsSelection = false
        table.separatorStyle = .none
        let footerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                        size: CGSize(width: 0, height: 115)))
        table.tableFooterView = footerView
        table.delegate = self
        table.isScrollEnabled = false
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
    
    init(viewModel: BodyParameterMonitorViewModelProtocol, contentModel: ParameterControlModuleModel) {
        self.viewModel = viewModel
        self.contentModel = contentModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Table View Delegate

extension BodyParameterMonitorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        46
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        67
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        HistorySectionHeaderView(appearanceModel: contentModel.historyHeaderAppearance)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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

private extension BodyParameterMonitorViewController {
    func setUpSubscriptions() {
        viewModel.tableDataPublisher
            .sink { [weak self] tableData in
                self?.dataSource.reload(tableData)
            }
            .store(in: &cancellables)
        
        viewModel.toastMessage
            .sink { [weak self] message in
                self?.presentToastMessage(ToastMessage(message: message))
            }
            .store(in: &cancellables)
    }
    
    @objc func addRecordButtonTapped() {
        viewModel.addRecordButtonTapped()
    }
}

// MARK: - Subviews configure + layout

private extension BodyParameterMonitorViewController {
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(widgetView)
        stackView.setCustomSpacing(16, after: widgetView)
        stackView.addArrangedSubview(graphView)
        stackView.addArrangedSubview(tableView)
        view.addSubview(addRecordButton)
    }
    
    func configure() {
        navigationItem.titleView = titleLabel
        view.backgroundColor = .generalBg
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        titleLabel.text = contentModel.screenTitle
        
        [scrollView, stackView, widgetView, graphView, tableView, addRecordButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            widgetView.heightAnchor.constraint(equalToConstant: 129),
            
            graphView.heightAnchor.constraint(equalToConstant: 369),
            
            addRecordButton.heightAnchor.constraint(equalToConstant: 48),
            addRecordButton.widthAnchor.constraint(equalToConstant: 48),
            addRecordButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addRecordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
