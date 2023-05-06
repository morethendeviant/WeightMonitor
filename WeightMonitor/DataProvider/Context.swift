//
//  Context.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import CoreData

final class Context {
    static let shared = Context().context
    static let coordinator = Context().persistentContainer.persistentStoreCoordinator
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    private init() {
        let modelName = "WeightCoreDataModel"
        self.persistentContainer = {
            let container = NSPersistentContainer(name: modelName)
            
//            let description = container.persistentStoreDescriptions.first
//            description?.setOption(true as NSNumber,
//                                           forKey: NSPersistentHistoryTrackingKey)
//            
//            let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
//                    description?.setOption(true as NSNumber,
//                                               forKey: remoteChangeKey)
            
            container.loadPersistentStores(completionHandler: { (_, error) in
                if error != nil {
                    fatalError("Can't load persistent container")
                }
            })
            return container
        }()
        
        self.context = persistentContainer.viewContext
    }
}
