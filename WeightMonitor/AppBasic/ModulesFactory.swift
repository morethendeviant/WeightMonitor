//
//  ModulesFactory.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

protocol ModulesFactoryProtocol {
    func makeWeightControlModule() -> (view: Presentable, coordinatable: BodyParameterControlModuleCoordinatable)
    func makeAddWeightRecordModule() -> (view: Presentable, coordinatable: BodyParameterRecordModuleCoordinatable)
    func makeEditWeightRecordModule(recordId: String) -> (view: Presentable, coordinatable: BodyParameterRecordModuleCoordinatable)
}

final class ModulesFactory: ModulesFactoryProtocol {
    func makeWeightControlModule() -> (view: Presentable, coordinatable: BodyParameterControlModuleCoordinatable) {
        let dataProvider = WeightDataProvider()
        let weightModuleModel = ModuleContentModel.weight
        let viewModel = BodyParameterControlViewModel(dataProvider: dataProvider,
                                                      unitsData: weightModuleModel.unitsConvertingData)

        let view = BodyParameterControlViewController(viewModel: viewModel,
                                                      contentModel: weightModuleModel.parameterControlModuleAppearance)
        return (view: view, coordinatable: viewModel)
    }
    
    func makeAddWeightRecordModule() -> (view: Presentable, coordinatable: BodyParameterRecordModuleCoordinatable) {
        let dataProvider = WeightDataProvider()
        let weightModuleModel = ModuleContentModel.weight
        let viewModel = BodyParameterRecordViewModel(dataProvider: dataProvider,
                                                        destination: .add,
                                                        unitsConvertingData: weightModuleModel.unitsConvertingData)

        let view = BodyParameterRecordViewController(viewModel: viewModel,
                                                        contentModel: weightModuleModel.addRecordModuleAppearance)
        return (view: view, coordinatable: viewModel)
    }
    
    func makeEditWeightRecordModule(recordId: String) -> (view: Presentable, coordinatable: BodyParameterRecordModuleCoordinatable) {
        let dataProvider = WeightDataProvider()
        let weightModuleModel = ModuleContentModel.weight
        let viewModel = BodyParameterRecordViewModel(dataProvider: dataProvider,
                                                        destination: .edit(recordId),
                                                        unitsConvertingData: weightModuleModel.unitsConvertingData)

        let view = BodyParameterRecordViewController(viewModel: viewModel,
                                                        contentModel: weightModuleModel.editRecordModuleAppearance)
        return (view: view, coordinatable: viewModel)
    }
}

enum RecordModuleDestination {
    case add
    case edit(String)
}
