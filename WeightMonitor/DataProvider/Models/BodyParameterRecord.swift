//
//  WeightRecord.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation

protocol BodyParameterRecord {
    var id: String { get }
    var parameter: Double { get }
    var date: Date { get }
}

struct Record: BodyParameterRecord {
    let id: String
    let parameter: Double
    let date: Date
}
