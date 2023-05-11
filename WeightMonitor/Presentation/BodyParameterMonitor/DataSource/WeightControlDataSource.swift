//
//  DataSource.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 03.05.2023.
//

import UIKit
import Combine

final class BodyParameterMonitorDataSource: UITableViewDiffableDataSource<Int, TableItemModel> {
    
    init(_ tableView: UITableView, widgetAppearance: WidgetAppearance) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableCell.identifier,
                                                           for: indexPath) as? HistoryTableCell
            else {
                return UITableViewCell()
            }
            
            cell.model = itemIdentifier
            return cell
        }
    }
    
    func reload(_ data: [TableItemModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        apply(snapshot, animatingDifferences: animated)
    }
}
