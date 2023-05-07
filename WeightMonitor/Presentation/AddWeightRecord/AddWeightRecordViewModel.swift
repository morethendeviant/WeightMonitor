//
//  AddWeightRecordViewModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 06.05.2023.
//

import Foundation
import Combine

protocol AddWeightRecordViewModelProtocol {
    var date: CurrentValueSubject<Date, Never> { get }
    var weight: CurrentValueSubject<String, Never> { get }
    var showDatePicker: CurrentValueSubject<Bool, Never> { get }
    var dateButtonLabel: CurrentValueSubject<String, Never> { get }
    var isCreateButtonEnabled: CurrentValueSubject<Bool, Never> { get }
    
    func createButtonTapped()
    func dateButtonTapped()
    func weightTextFieldIsBeingEditing()
}

final class AddWeightRecordViewModel {
    var showDatePicker = CurrentValueSubject<Bool, Never>(false)
    var dateButtonLabel = CurrentValueSubject<String, Never>("")
    var date = CurrentValueSubject<Date, Never>(Date())
    var weight = CurrentValueSubject<String, Never>("")
    var isCreateButtonEnabled = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables: Set<AnyCancellable> = []
    private var dataProvider = WeightDataProvider()
    
    init() {
        setSubscriptions()
    }
}

extension AddWeightRecordViewModel: AddWeightRecordViewModelProtocol {
    func dateButtonTapped() {
        showDatePicker.send(true)
    }
    
    func weightTextFieldIsBeingEditing() {
        showDatePicker.send(false)
    }
    
    func createButtonTapped() {
        let record = Record(id: UUID().uuidString, weight: Double(weight.value) ?? 0, date: date.value.onlyDate())
        try? dataProvider.addRecord(record)
    }
}

extension AddWeightRecordViewModel {
    func setSubscriptions() {
        date.sink { [weak self] date in
            self?.dateButtonLabel.send(date.onlyDate() == Date().onlyDate() ? "Сегодня" : date.toString(format: "dd MMM yyyy"))
        }
        .store(in: &cancellables)
        
        weight.sink { [weak self] weight in
            if weight.isEmpty {
                self?.isCreateButtonEnabled.send(false)
            } else {
                self?.isCreateButtonEnabled.send(true)
            }
        }
        .store(in: &cancellables)
    }
}
