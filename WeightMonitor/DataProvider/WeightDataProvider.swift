//
//  BodyParameterDataProvider.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation
import CoreData
import Combine

protocol BodyParameterDataProviderProtocol {
    var contentPublisher: AnyPublisher<Notification, Never> { get }
    
    func fetchData() throws -> [BodyParameterRecord]
    func deleteRecord(id: String) throws
}

protocol AddBodyParameterRecordDataProviderProtocol {
    func addRecord(_ record: BodyParameterRecord) throws
}

final class WeightDataProvider {
    let context = Context.shared
}

extension WeightDataProvider: BodyParameterDataProviderProtocol {
    var contentPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave,
                       object: Context.shared)
            .eraseToAnyPublisher()
    }

    func deleteRecord(id: String) throws {
        let request = NSFetchRequest<WeightRecordManagedObject>(entityName: "WeightRecordCodeData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(WeightRecordManagedObject.id), id)
        guard let recordObject = try context.fetch(request).first else { return }
        context.delete(recordObject)
        try context.save()
    }
    
    func fetchData() throws -> [BodyParameterRecord] {
        let request = NSFetchRequest<WeightRecordManagedObject>(entityName: "WeightRecordCodeData")
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let weightObjects = try context.fetch(request)
        return weightObjects.map { Record(id: $0.id, parameter: $0.weight, date: $0.date) }
    }
}

extension WeightDataProvider: AddBodyParameterRecordDataProviderProtocol {
    func addRecord(_ record: BodyParameterRecord) throws {
        let weightRecordObject = WeightRecordManagedObject(context: context)
        weightRecordObject.id = record.id
        weightRecordObject.weight = record.parameter
        weightRecordObject.date = record.date
        try context.save()
    }
}
