//
//  AddWeightRecordViewModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 06.05.2023.
//

import Foundation
import Combine

protocol AddBodyParameterRecordModuleCoordinatable {
    var finish: (() -> Void)? { get set }
}

protocol AddBodyParameterRecordViewModelProtocol {
    var date: CurrentValueSubject<Date, Never> { get }
    var parameter: CurrentValueSubject<String, Never> { get }
    var showDatePicker: CurrentValueSubject<Bool, Never> { get }
    var dateButtonLabel: CurrentValueSubject<String, Never> { get }
    var isCreateButtonEnabled: CurrentValueSubject<Bool, Never> { get }
    var unitsName: CurrentValueSubject<String, Never> { get }
    
    func createButtonTapped()
    func dateButtonTapped()
    func parameterTextFieldIsBeingEditing()
}

final class AddBodyParameterRecordViewModel: AddBodyParameterRecordModuleCoordinatable {
    var finish: (() -> Void)?
    
    var showDatePicker = CurrentValueSubject<Bool, Never>(false)
    var dateButtonLabel = CurrentValueSubject<String, Never>("")
    var date = CurrentValueSubject<Date, Never>(Date())
    var parameter = CurrentValueSubject<String, Never>("")
    var isCreateButtonEnabled = CurrentValueSubject<Bool, Never>(false)
    var unitsName = CurrentValueSubject<String, Never>("")

    private var cancellables: Set<AnyCancellable> = []
    private var dataProvider: AddBodyParameterRecordDataProviderProtocol
    private var unitsConvertingData: UnitsConvertingData
    private var userDefaultsMetric: Bool {
        UserDefaults.standard.bool(forKey: "metric")
    }
    
    init(dataProvider: AddBodyParameterRecordDataProviderProtocol, unitsConvertingData: UnitsConvertingData) {
        self.dataProvider = dataProvider
        self.unitsConvertingData = unitsConvertingData
        setSubscriptions()
    }
}

extension AddBodyParameterRecordViewModel: AddBodyParameterRecordViewModelProtocol {
    func dateButtonTapped() {
        showDatePicker.send(true)
    }
    
    func parameterTextFieldIsBeingEditing() {
        showDatePicker.send(false)
    }
    
    func createButtonTapped() {
        let id = UUID().uuidString
        let multiplier =  userDefaultsMetric ? unitsConvertingData.metricUnitsMultiplier : unitsConvertingData.imperialUnitsMultiplier
        let parameter = (Double(parameter.value.replacingOccurrences(of: ",", with: ".")) ?? 0) / multiplier
        let date = date.value.onlyDate()
        let record = Record(id: id, parameter: parameter, date: date)
        try? dataProvider.addRecord(record)
        finish?()
    }
}

extension AddBodyParameterRecordViewModel {
    func setSubscriptions() {
        date.sink { [weak self] date in
            self?.dateButtonLabel.send(date.onlyDate() == Date().onlyDate() ? "Сегодня" : date.toString(format: "dd MMM yyyy"))
        }
        .store(in: &cancellables)
        
        parameter.sink { [weak self] parameter in
            if parameter.isEmpty {
                self?.isCreateButtonEnabled.send(false)
            } else {
                self?.isCreateButtonEnabled.send(true)
            }
        }
        .store(in: &cancellables)
        
        UserDefaults.standard.publisher(for: \.metric).sink { [weak self] metric in
            guard let self else { return }
            let units = metric ? self.unitsConvertingData.metricUnitsName : self.unitsConvertingData.imperialUnitsName
            self.unitsName.send(units)
        }
        .store(in: &cancellables)
    }
}
