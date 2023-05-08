//
//  BaseCoordinator.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

protocol Coordinatable: AnyObject {
    func startFlow()
}

class BaseCoordinator {
    
    var childCoordinators: [Coordinatable] = []
  
    func addDependency(_ coordinator: Coordinatable) {
        childCoordinators.forEach { childCoordinator in
            if childCoordinator === coordinator { return }
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinatable?) {
        guard let coordinator = coordinator else { return }
        childCoordinators.removeAll { childCoordinator in
            childCoordinator === coordinator
        }
    }
}
