//
//  WeightRecordManagedObject.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation
import CoreData

@objc(WeightRecordManagedObject)
final class WeightRecordManagedObject: NSManagedObject, WeightRecord {
    @NSManaged var id: String
    @NSManaged var weight: Double
    @NSManaged var date: Date
}
