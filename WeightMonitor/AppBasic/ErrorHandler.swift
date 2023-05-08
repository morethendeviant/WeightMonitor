//
//  ErrorHandler.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 08.05.2023.
//

import Foundation

final class ErrorHandler {
    static let shared = ErrorHandler()
    
    func handle(error: Error) {
        print(error.localizedDescription)
    }
    
    private init() { }
}
