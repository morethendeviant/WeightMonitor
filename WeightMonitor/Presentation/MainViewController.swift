//
//  ViewController.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 02.05.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    private lazy var dataSource = DataSource(tableView)
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Монитор веса"
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

        table.delegate = self
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var addRecordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 24
        button.backgroundColor = .mainAccent
        let image = UIImage(systemName: "plus",
                            withConfiguration: UIImage.SymbolConfiguration (pointSize: 18, weight: .bold))
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleLabel
        view.backgroundColor = .generalBg
        
        addSubviews()
        configure()
        applyLayout()
        
        tableView.dataSource = dataSource
        let widgetData = SectionData(key: .widget,
                                       values: [.widgetCell(WidgetItem(widgetTitle: "Текущий вес",
                                                                       primaryValue: "82.5 кг",
                                                                       secondaryValue: "-0.5 кг",
                                                                       isMetricOn: true))])
        
        let graphData = SectionData(key: .graph, values: [.graphCell(GraphItem(selectedMonth: 0,
                                                                               value: "",
                                                                               date: ""))])
        
        let historyData = SectionData(key: .table, values: [.tableCell(TableItem(value: "82.5 кг",
                                                                                 valueDelta: "-0.5 кг",
                                                                                 date: "2 мар")),
                                                            .tableCell(TableItem(value: "80.0 кг",
                                                                                 valueDelta: "+2.5 кг",
                                                                                 date: "30 апр"))])
        
        dataSource.reload([widgetData, graphData, historyData])
    }
}

extension MainViewController: UITableViewDelegate {
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
            let model = HistorySectionHeaderModel(primaryColumnTitle: "Вес",
                                    secondaryColumnTitle: "Изменения",
                                    tertiaryColumnTitle: "Дата")
            let header = HistorySectionHeaderView()
            header.model = model
            
            return header
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
}





// MARK: - Subviews configure + layout
private extension MainViewController {
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(addRecordButton)
    }
    
    func configure() {
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
            addRecordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

        ])
    }
}
