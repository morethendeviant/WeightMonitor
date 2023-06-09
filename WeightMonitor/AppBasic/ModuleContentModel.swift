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
            let historySectionAppearance = HistorySectionHeaderAppearance(headerTitle: "История",
                                                                   primaryColumnTitle: "Вес",
                                                                   secondaryColumnTitle: "Измерения",
                                                                   tertiaryColumnTitle: "Дата")

            return ParameterControlModuleModel(screenTitle: "Монитор веса",
                                               widgetAppearance: widgetAppearance,
                                               historyHeaderAppearance: historySectionAppearance)
        }
    }
    
    var addRecordModuleAppearance: RecordModuleModel {
        switch self {
        case .weight:
            let addBodyParameterAppearance = BodyParameterAppearance(parameterName: "Вес",
                                                                        confirmButtonName: "Добавить")
            return RecordModuleModel(screenTitle: "Добавить вес",
                                        bodyParameterAppearance: addBodyParameterAppearance)
        }
    }
    
    var editRecordModuleAppearance: RecordModuleModel {
        switch self {
        case .weight:
            let editBodyParameterAppearance = BodyParameterAppearance(parameterName: "Вес",
                                                                        confirmButtonName: "Изменить")
            return RecordModuleModel(screenTitle: "Редактировать вес",
                                        bodyParameterAppearance: editBodyParameterAppearance)
        }
    }
    
    var unitsConvertingData: UnitsConvertingData {
        switch self {
        case .weight:
            return UnitsConvertingData(metricUnitsName: "кг",
                                                   metricUnitsMultiplier: 1.0,
                                                   imperialUnitsName: "lb",
                                                   imperialUnitsMultiplier: 2.205)
        }
    }
}
