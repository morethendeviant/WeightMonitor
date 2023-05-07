//
//  ModuleContentModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

enum ModuleContentModel {
    case weight(WeightModuleModel)
}


struct WeightModuleModel {
    let mainScreenTitle: String
    let subScreenTitle: String
    let historyHeader: HistorySectionHeaderModel
    let units: String
}
