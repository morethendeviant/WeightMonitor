//
//  SectionItem.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

enum SectionItem: Hashable {
    case widgetCell(WidgetItem)
    case graphCell(GraphItem)
    case tableCell(TableItem)
}
