//
//  DataSource.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 03.05.2023.
//

import UIKit

final class WeightControlDataSource: UITableViewDiffableDataSource<Section, SectionItem> {
    
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .widgetCell(let model):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: WidgetCell.identifier,
                                                               for: indexPath) as? WidgetCell
                else {
                    return UITableViewCell()
                }
                cell.model = model
                return cell
            case .graphCell:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: GraphCell.identifier,
                                                               for: indexPath) as? GraphCell
                else {
                    return UITableViewCell()
                }

                return cell
            case .tableCell(let model):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableCell.identifier,
                                                               for: indexPath) as? HistoryTableCell
                else {
                    return UITableViewCell()
                }

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
