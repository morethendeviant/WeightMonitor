//
//  Date+Ext.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation

extension Date {
    func toString(format: String = "d MMM") -> String {
           let formatter = DateFormatter()
           formatter.dateStyle = .short
           formatter.dateFormat = format
           return formatter.string(from: self)
       }
    
    func onlyDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date ?? Date()
    }
    
    func onlyMonthYear() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        let date = Calendar.current.date(from: components)
        return date ?? Date()
    }
    
    func onlyDay() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: self)
        let date = Calendar.current.date(from: components)
        return date ?? Date()
    }
    
    func addOrSubtractMonth(month: Int) -> Self? {
        Calendar.current.date(byAdding: .month, value: month, to: self)
    }
}
