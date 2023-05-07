//
//  UserDefaults+Ext.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import Foundation

extension UserDefaults {
    @objc dynamic var metric: Bool {
            return bool(forKey: "metric")
        }}
