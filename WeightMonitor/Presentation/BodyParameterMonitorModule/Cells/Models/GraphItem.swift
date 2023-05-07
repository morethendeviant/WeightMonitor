//
//  GraphItem.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

struct GraphItem: Hashable {
    let monthName: String
    let isPreviousButtonEnabled: Bool
    let isNextButtonEnabled: Bool
    let graphData: [GraphData]
}

struct GraphData: Hashable {
    let value: Double
    let date: Date
}
