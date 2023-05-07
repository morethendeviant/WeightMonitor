//
//  ModuleContentModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

enum ModuleContentModel {
    case weight
    
    var model: ModuleModel {
        switch self {
        case .weight:
            let historySectionHeaderModel = HistorySectionHeaderModel(primaryColumnTitle: "Вес",
                                                                      secondaryColumnTitle: "Измерения",
                                                                      tertiaryColumnTitle: "Дата")
            return ModuleModel(mainScreenTitle: "Монитор веса",
                               subScreenTitle: "Добавить вес",
                               historyHeader: historySectionHeaderModel,
                               units: "кг")
        }
    }
}

struct ModuleModel {
    let mainScreenTitle: String
    let subScreenTitle: String
    let historyHeader: HistorySectionHeaderModel
    let units: String
}
