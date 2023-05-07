//
//  ModulesFactory.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

protocol ModulesFactoryProtocol {
    func makeWeightControlModule() -> (view: Presentable, coordinatable: BodyParameterControlModuleCoordinatable)
    func makeAddWeightRecordModule() -> (view: Presentable, coordinatable: AddBodyParameterRecordModuleCoordinatable)
}

final class ModulesFactory: ModulesFactoryProtocol {
    func makeWeightControlModule() -> (view: Presentable, coordinatable: BodyParameterControlModuleCoordinatable) {
        let dataProvider = WeightDataProvider()
        let viewModel = BodyParameterControlViewModel(dataProvider: dataProvider)
        let weightModuleModel = ModuleContentModel.weight
        
        let view = BodyParameterControlViewController(viewModel: viewModel, contentModel: weightModuleModel.model)
        return (view: view, coordinatable: viewModel)
    }
    
    func makeAddWeightRecordModule() -> (view: Presentable, coordinatable: AddBodyParameterRecordModuleCoordinatable) {
        let dataProvider = WeightDataProvider()
        let viewModel = AddBodyParameterRecordViewModel(dataProvider: dataProvider)
        let weightModuleModel = ModuleContentModel.weight

        let view = AddBodyParameterRecordViewController(viewModel: viewModel, contentModel: weightModuleModel.model)
        return (view: view, coordinatable: viewModel)
    }
}
