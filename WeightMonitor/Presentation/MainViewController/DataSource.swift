//
//  DataSource.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 03.05.2023.
//

import UIKit

final class DataSource: UITableViewDiffableDataSource<Section, SectionItem> {
    
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .widgetCell(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: WidgetCell.identifier, for: indexPath) as! WidgetCell
                cell.selectionStyle = .none
                cell.model = model
                return cell
            case .graphCell:
                let cell = tableView.dequeueReusableCell(withIdentifier: GraphCell.identifier, for: indexPath) as! GraphCell
                cell.selectionStyle = .none
                return cell
            case .tableCell(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableCell.identifier, for: indexPath) as! HistoryTableCell
                cell.model = model
                return cell
            }
            
        }
    }
    
    func reload(_ data: [SectionData], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(data.map { $0.key })
        data.forEach { item in
            snapshot.appendItems(item.values, toSection: item.key)
        }
        
        apply(snapshot, animatingDifferences: animated)
    }
}



enum Section: Hashable {
    case widget
    case graph
    case table
}

enum SectionItem: Hashable {
    case widgetCell(WidgetItem)
    case graphCell(GraphItem)
    case tableCell(TableItem)
}

struct SectionData {
    var key: Section
    var values: [SectionItem]
}

