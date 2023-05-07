//
//  WeightDataProvider.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation
import CoreData
import Combine

protocol WeightDataProviderProtocol {
    var contentPublisher: AnyPublisher<Notification, Never> { get }
    
    func fetchWeightData() throws -> [WeightRecord]
    func addRecord(_ record: WeightRecord) throws
    func deleteRecord(id: String) throws
}

final class WeightDataProvider {
    let context = Context.shared
}

extension WeightDataProvider: WeightDataProviderProtocol {
    var contentPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave,
                       object: Context.shared)
//            .compactMap {
//                guard let managedObjects = $0.userInfo,
//                      let managedObjectsSet = managedObjects[NSInsertedObjectsKey] as? Set<WeightRecordManagedObject>,
//                      let managedObject = managedObjectsSet.first
//                else {
//                    return nil
//                }
//                print("publish")
//                return Record(id: managedObject.id, weight: managedObject.weight, date: managedObject.date)
//            }
            .eraseToAnyPublisher()
            
    }
    
    func addRecord(_ record: WeightRecord) throws {
        let weightRecordObject = WeightRecordManagedObject(context: context)
        weightRecordObject.id = record.id
        weightRecordObject.weight = record.weight
        weightRecordObject.date = record.date
        try context.save()
    }
    
    func deleteRecord(id: String) throws {
        let request = NSFetchRequest<WeightRecordManagedObject>(entityName: "WeightRecordCodeData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(WeightRecordManagedObject.id), id)
        guard let recordObject = try context.fetch(request).first else { return }
        context.delete(recordObject)
        try context.save()
        print("deleted")
    }
    
    func fetchWeightData() throws -> [WeightRecord] {
        let request = NSFetchRequest<WeightRecordManagedObject>(entityName: "WeightRecordCodeData")
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try context.fetch(request)
    }
}
