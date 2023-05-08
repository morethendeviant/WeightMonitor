//
//  AddWeightRecordViewModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 06.05.2023.
//

import Foundation
import Combine

protocol BodyParameterRecordModuleCoordinatable {
    var finish: (() -> Void)? { get set }
}

protocol BodyParameterRecordViewModelProtocol {
    var date: CurrentValueSubject<Date, Never> { get }
    var parameter: CurrentValueSubject<String, Never> { get }
    var showDatePicker: CurrentValueSubject<Bool, Never> { get }
    var dateButtonLabel: CurrentValueSubject<String, Never> { get }
    var isConfirmButtonEnabled: CurrentValueSubject<Bool, Never> { get }
    var unitsName: CurrentValueSubject<String, Never> { get }
    
    func viewDidLoad()
    func confirmButtonTapped()
    func dateButtonTapped()
    func parameterTextFieldIsBeingEditing()
}

final class BodyParameterRecordViewModel: BodyParameterRecordModuleCoordinatable {
    
    var finish: (() -> Void)?
    
    var showDatePicker = CurrentValueSubject<Bool, Never>(false)
    var dateButtonLabel = CurrentValueSubject<String, Never>("")
    var date = CurrentValueSubject<Date, Never>(Date())
    var parameter = CurrentValueSubject<String, Never>("")
    var isConfirmButtonEnabled = CurrentValueSubject<Bool, Never>(false)
    var unitsName = CurrentValueSubject<String, Never>("")

    private var cancellables: Set<AnyCancellable> = []
    private var dataProvider: BodyParameterRecordDataProviderProtocol
    private var destination: RecordModuleDestination
    private var unitsConvertingData: UnitsConvertingData
    private var userDefaultsMetric: Bool {
        UserDefaults.standard.bool(forKey: "metric")
    }
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? ""
    }
    
    init(dataProvider: BodyParameterRecordDataProviderProtocol,
         destination: RecordModuleDestination,
         unitsConvertingData: UnitsConvertingData) {
        self.dataProvider = dataProvider
        self.destination = destination
        self.unitsConvertingData = unitsConvertingData
        setSubscriptions()
    }
}

extension BodyParameterRecordViewModel: BodyParameterRecordViewModelProtocol {
    func viewDidLoad() {
        switch destination {
        case .add: break
        case .edit(let recordId):
            guard let record = try? dataProvider.fetchRecord(recordId) else { return }
            
            let multiplier =  userDefaultsMetric ? unitsConvertingData.metricUnitsMultiplier : unitsConvertingData.imperialUnitsMultiplier
            
            parameter.send(String(format: "%.1f", record.parameter * multiplier)
                                                        .replacingOccurrences(of: ".", with: decimalSeparator))
            date.send(record.date)
            
            print(parameter.value)
        }
    }
    
    func dateButtonTapped() {
        showDatePicker.send(true)
    }
    
    func parameterTextFieldIsBeingEditing() {
        showDatePicker.send(false)
    }
    
    func confirmButtonTapped() {
        var recordId: String
        
        switch destination {
        case .add: recordId = UUID().uuidString
        case .edit(let id): recordId = id
        }
        
        let multiplier =  userDefaultsMetric ? unitsConvertingData.metricUnitsMultiplier : unitsConvertingData.imperialUnitsMultiplier
        let parameter = (Double(parameter.value.replacingOccurrences(of: ",", with: ".")) ?? 0) / multiplier
        let date = date.value.onlyDate()
        let record = BodyParameterRecord(id: recordId, parameter: parameter, date: date)
        
        switch destination {
        case .add: try? dataProvider.addRecord(record)
        case .edit: try? dataProvider.editRecord(record)
        }
        
        finish?()
    }
}

// MARK: - Private Methods

private extension BodyParameterRecordViewModel {
    func setSubscriptions() {
        date.sink { [weak self] date in
            self?.dateButtonLabel.send(date.onlyDate() == Date().onlyDate() ? "Сегодня" : date.toString(format: "dd MMM yyyy"))
        }
        .store(in: &cancellables)
        
        parameter.sink { [weak self] parameter in
            if parameter.isEmpty {
                self?.isConfirmButtonEnabled.send(false)
            } else {
                self?.isConfirmButtonEnabled.send(true)
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
