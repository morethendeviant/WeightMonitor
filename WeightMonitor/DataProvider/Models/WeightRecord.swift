//
//  WeightRecord.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation

protocol WeightRecord {
    var id: String { get }
    var weight: Double { get }
    var date: Date { get }
}

struct Record: WeightRecord {
    let id: String
    let weight: Double
    let date: Date
}
