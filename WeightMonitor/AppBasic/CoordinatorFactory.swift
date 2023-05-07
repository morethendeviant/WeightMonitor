//
//  CoordinatorFactory.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

protocol CoordinatorsFactoryProtocol {
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput 
    func makeBodyParameterModuleCoordinator(router: Routable) -> Coordinatable & WeightModuleCoordinatorOutput
}

final class CoordinatorFactory {
    private let modulesFactory: ModulesFactoryProtocol = ModulesFactory()
}

extension CoordinatorFactory: CoordinatorsFactoryProtocol {
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput {
        AppCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
    
    func makeBodyParameterModuleCoordinator(router: Routable) -> Coordinatable & WeightModuleCoordinatorOutput {
        WeightModuleCoordinator(modulesFactory: modulesFactory, router: router)
    }
}
