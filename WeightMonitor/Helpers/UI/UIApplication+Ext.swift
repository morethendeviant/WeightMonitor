//
//  UIApplication+Ext.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 07.05.2023.
//

import UIKit

extension UIApplication {
    var keyWindowScene: UIWindowScene? {
            return self
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first
        }
}
