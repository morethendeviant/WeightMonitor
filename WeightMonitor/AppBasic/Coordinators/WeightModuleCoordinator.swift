//
//  WeightModuleCoordinator.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

protocol WeightModuleCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class WeightModuleCoordinator: BaseCoordinator, Coordinatable {
    var finishFlow: (() -> Void)?
       
       private var modulesFactory: ModulesFactoryProtocol
       private var router: Routable
       
       init(modulesFactory: ModulesFactoryProtocol, router: Routable) {
           self.modulesFactory = modulesFactory
           self.router = router
       }
    
    func startFlow() {
        performFlow()
    }
}

extension WeightModuleCoordinator: WeightModuleCoordinatorOutput {
    func performFlow() {
        let weightModule = modulesFactory.makeWeightControlModule()
        let weightModuleView = weightModule.view
        var weightModuleCoordinatable = weightModule.coordinatable
        
        weightModuleCoordinatable.headForAddRecord = { [weak self, weak router] in
            guard let self else { return }
            
            let addRecordModule = self.modulesFactory.makeAddWeightRecordModule()
            let addRecordModuleView = addRecordModule.view
            var addRecordModuleCoordinatable = addRecordModule.coordinatable
            
            addRecordModuleCoordinatable.finish = { [weak addRecordModuleView] in
                router?.dismissModule(addRecordModuleView)
            }
            
            router?.present(addRecordModuleView)
        }
        
        weightModuleCoordinatable.headForEditRecord = { [weak self, weak router] id in
            guard let self else { return }
            
            let editRecordModule = self.modulesFactory.makeEditWeightRecordModule(recordId: id)
            let editRecordModuleView = editRecordModule.view
            var editRecordModuleCoordinatable = editRecordModule.coordinatable
            
            editRecordModuleCoordinatable.finish = { [weak editRecordModuleView] in
                router?.dismissModule(editRecordModuleView)
            }
            
            router?.present(editRecordModuleView)
            
        }
        
        router.push(weightModuleView)
    }
}
