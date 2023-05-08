//
//  BodyParameterDataProvider.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation
import CoreData
import Combine

enum DataProviderError: Error {
    case fetchError
}

enum NotificationEvent: String, CaseIterable {
    case inserted, deleted, updated
}

protocol BodyParameterControlDataProviderProtocol {
    var contentPublisher: AnyPublisher<NotificationEvent, Never> { get }
    
    func fetchData() throws -> [BodyParameterRecord]
    func deleteRecord(id: String) throws
}

protocol BodyParameterRecordDataProviderProtocol {
    func fetchRecord(_ id: String) throws -> BodyParameterRecord
    func addRecord(_ record: BodyParameterRecord) throws
    func editRecord(_ record: BodyParameterRecord) throws
}

final class WeightDataProvider {
    let context = Context.shared
}

// MARK: - Body Parameter Control

extension WeightDataProvider: BodyParameterControlDataProviderProtocol {
    var contentPublisher: AnyPublisher<NotificationEvent, Never> {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave,
                       object: Context.shared)
            .compactMap({ notification in
                guard let keys = notification.userInfo?.keys else { return nil }
                
                let events = NotificationEvent.allCases.filter { event in
                    keys.contains(event.rawValue)
                }
                
                guard let event = events.first else { return nil }
                
                return event
            })
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
        return weightObjects.map { BodyParameterRecord(id: $0.id, parameter: $0.weight, date: $0.date) }
    }
}

// MARK: - Body Parameter Record

extension WeightDataProvider: BodyParameterRecordDataProviderProtocol {
    func fetchRecord(_ id: String) throws -> BodyParameterRecord {
        let request = NSFetchRequest<WeightRecordManagedObject>(entityName: "WeightRecordCodeData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(WeightRecordManagedObject.id), id)
        request.returnsObjectsAsFaults = false
        let weightObjects = try context.fetch(request)
        guard let weightObject = weightObjects.first else { throw DataProviderError.fetchError }
        return BodyParameterRecord(id: weightObject.id, parameter: weightObject.weight, date: weightObject.date)
    }
    
    func editRecord(_ record: BodyParameterRecord) throws {
        let request = NSFetchRequest<WeightRecordManagedObject>(entityName: "WeightRecordCodeData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(WeightRecordManagedObject.id), record.id)
        request.returnsObjectsAsFaults = false
        let weightObjects = try context.fetch(request)
        guard let weightObject = weightObjects.first else { return }
        
        weightObject.weight = record.parameter
        weightObject.date = record.date
        try context.save()
    }
    
    func addRecord(_ record: BodyParameterRecord) throws {
        let weightRecordObject = WeightRecordManagedObject(context: context)
        weightRecordObject.id = record.id
        weightRecordObject.weight = record.parameter
        weightRecordObject.date = record.date
        try context.save()
    }
}
