//
//  Date+Ext.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation

extension Date {
    func toString(format: String = "dd MM") -> String {
           let formatter = DateFormatter()
           formatter.dateStyle = .short
           formatter.dateFormat = format
           return formatter.string(from: self)
       }
}
