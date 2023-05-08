//
//  String+Ext.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 08.05.2023.
//

import Foundation

extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}
