//
//  WidgetItem.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Combine

struct WidgetItem: Hashable {
    static func == (lhs: WidgetItem, rhs: WidgetItem) -> Bool {
        lhs.primaryValue == rhs.primaryValue &&
        lhs.secondaryValue == rhs.secondaryValue &&
        lhs.isMetricOn == rhs.isMetricOn
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(primaryValue)
    }
    
    let primaryValue: String
    let secondaryValue: String
    let isMetricOn: Bool
    let metricSwitchPublisher: PassthroughSubject<Bool, Never>
}
