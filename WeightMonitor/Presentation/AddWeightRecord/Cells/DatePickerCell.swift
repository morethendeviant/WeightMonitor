//
//  DatePickerCell.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 06.05.2023.
//

import UIKit
import Combine

final class DatePickerCell: UITableViewCell {
    
    var date = CurrentValueSubject<Date, Never>(Date())

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(nil, action: #selector(dateChanged), for: .valueChanged)
        picker.locale = Locale(identifier: "ru_RU")
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        picker.datePickerMode = .date
        picker.calendar = calendar
        picker.maximumDate = Date()
        return picker
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        configure()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DatePickerCell {
    @objc func dateChanged() {
        date.send(datePicker.date)
    }
}


// MARK: - Subviews configure + layout
private extension DatePickerCell {
    func addSubviews() {
        contentView.addSubview(datePicker)
    }
    
    func configure() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func applyLayout() {
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
