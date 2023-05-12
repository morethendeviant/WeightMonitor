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
    
    private(set) var showDatePicker = CurrentValueSubject<Bool, Never>(false)
    private(set) var dateButtonLabel = CurrentValueSubject<String, Never>("")
    private(set) var date = CurrentValueSubject<Date, Never>(Date())
    private(set) var parameter = CurrentValueSubject<String, Never>("")
    private(set) var isConfirmButtonEnabled = CurrentValueSubject<Bool, Never>(false)
    private(set) var unitsName = CurrentValueSubject<String, Never>("")

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

// MARK: - View Model Protocol

extension BodyParameterRecordViewModel: BodyParameterRecordViewModelProtocol {
    func viewDidLoad() {
        switch destination {
        case .add: break
        case .edit(let recordId):
            do {
                let record = try dataProvider.fetchRecord(recordId)
                let multiplier =  userDefaultsMetric ? unitsConvertingData.metricUnitsMultiplier : unitsConvertingData.imperialUnitsMultiplier
                
                parameter.send(String(format: "%.1f", record.parameter * multiplier)
                                                            .replacingOccurrences(of: ".", with: decimalSeparator))
                date.send(record.date)
            } catch {
                ErrorHandler.shared.handle(error: error)
            }
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
        guard let parameter = Double(parameter.value.replacingOccurrences(of: ",", with: ".")) else {  return }
        
        let date = date.value
        let record = BodyParameterRecord(id: recordId, parameter: parameter / multiplier, date: date)
        
        switch destination {
        case .add:
            do {
                try dataProvider.addRecord(record)
            } catch {
                ErrorHandler.shared.handle(error: error)
            }
            
        case .edit:
            do {
                try dataProvider.editRecord(record)
            } catch {
                ErrorHandler.shared.handle(error: error)
            }
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
