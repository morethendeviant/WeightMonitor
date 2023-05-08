//
//  ToastModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

struct ToastMessage {
    let message: String
    let style: ToastStyle?
    
    init(message: String, style: ToastStyle? = nil) {
        self.message = message
        self.style = style
    }
}
