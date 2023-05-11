//
//  IntrinsicTableView.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 11.05.2023.
//

import UIKit

final class IntrinsicTableView: UITableView {

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

}
