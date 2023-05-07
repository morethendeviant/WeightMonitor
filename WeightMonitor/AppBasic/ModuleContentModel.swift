//
//  ModuleContentModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

enum ModuleContentModel {
    case weight
    
    var parameterControlModuleAppearance: ParameterControlModuleModel {
        switch self {
        case .weight:
            let widgetAppearance = WidgetAppearance(widgetTitle: "Текущий вес", imageName: "scales")
            let graphSectionAppearance = GraphSectionHeaderAppearance(headerTitle: "Измерения за месяц")
            let historySectionAppearance = HistorySectionHeaderAppearance(headerTitle: "История",
                                                                   primaryColumnTitle: "Вес",
                                                                   secondaryColumnTitle: "Измерения",
                                                                   tertiaryColumnTitle: "Дата")

            return ParameterControlModuleModel(screenTitle: "Монитор веса",
                                               widgetAppearance: widgetAppearance,
                                               graphHeaderAppearance: graphSectionAppearance,
                                               historyHeaderAppearance: historySectionAppearance)
        }
    }
    
    var parameterControlModuleUnitsData: ParameterControlModuleUnitsData {
        switch self {
        case .weight:
            return ParameterControlModuleUnitsData(metricUnitsName: "кг",
                                                   metricUnitsMultiplier: 1.0,
                                                   imperialUnitsName: "lb",
                                                   imperialUnitsMultiplier: 2.205)
        }
    }
    
    
    
    var addRecordModuleAppearance: AddRecordModuleModel {
        switch self {
        case .weight:
            let addBodyParameterAppearance = AddBodyParameterAppearance(parameterName: "Вес",
                                                                        unitsName: "кг")
            return AddRecordModuleModel(screenTitle: "Добавить вес",
                                        addBodyParameterAppearance: addBodyParameterAppearance)
        }
    }
}

struct ParameterControlModuleModel {
    let screenTitle: String
    let widgetAppearance: WidgetAppearance
    let graphHeaderAppearance: GraphSectionHeaderAppearance
    let historyHeaderAppearance: HistorySectionHeaderAppearance
}

struct AddRecordModuleModel {
    let screenTitle: String
    let addBodyParameterAppearance: AddBodyParameterAppearance
}

struct ParameterControlModuleUnitsData {
    let metricUnitsName: String
    let metricUnitsMultiplier: Double
    let imperialUnitsName: String
    let imperialUnitsMultiplier: Double
}
