//
//  AppCoordinator.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

protocol AppCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class AppCoordinator: BaseCoordinator, Coordinatable, AppCoordinatorOutput {
    
    var finishFlow: (() -> Void)?
    
    private var coordinatorsFactory: CoordinatorsFactoryProtocol
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable) {
        self.coordinatorsFactory = coordinatorsFactory
        self.modulesFactory = modulesFactory
        self.router = router
    }
    
    func startFlow() {
        routeToNavController()
        routeToWeightControlModule()
    }
}

extension AppCoordinator {
    func routeToNavController() {
        let navController = ModuleNavController()
        router.setRootViewController(viewController: navController)
    }
    
    func routeToWeightControlModule() {
        let weightModuleCoordinator = coordinatorsFactory.makeBodyParameterModuleCoordinator(router: router)
        addDependency(weightModuleCoordinator)
        weightModuleCoordinator.startFlow()
    }
}
