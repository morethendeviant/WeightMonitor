//
//  GraphItem.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation
import Combine

struct GraphItem: Hashable {
    let monthName: String
    let isPreviousButtonEnabled: Bool
    let isNextButtonEnabled: Bool
    let graphData: [GraphData]
    
    let previousButtonPublisher: PassthroughSubject<Void, Never>
    let nextButtonPublisher: PassthroughSubject<Void, Never>
}

extension GraphItem {
    static func == (lhs: GraphItem, rhs: GraphItem) -> Bool {
        lhs.monthName == rhs.monthName &&
        lhs.isPreviousButtonEnabled == rhs.isPreviousButtonEnabled &&
        lhs.isNextButtonEnabled == rhs.isNextButtonEnabled &&
        lhs.graphData == rhs.graphData
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(monthName)
    }
}

struct GraphData: Hashable, Identifiable {
    let id: String
    let value: Double
    let date: Date
}

