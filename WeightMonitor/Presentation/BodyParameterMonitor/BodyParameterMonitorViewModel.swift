//
//  bodyParameterControlViewModel.swift
//  bodyParameterMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation
import Combine

protocol BodyParameterMonitorModuleCoordinatable {
    var headForAddRecord: (() -> Void)? { get set }
    var headForEditRecord: ((String) -> Void)? { get set }
}

protocol BodyParameterMonitorViewModelProtocol {
    var widgetDataPublisher: PassthroughSubject<WidgetModel, Never> { get }
    var graphDataPublisher: PassthroughSubject<GraphModel, Never> { get }
    var tableDataPublisher: PassthroughSubject<[TableItemModel], Never> { get }
    var toastMessage: PassthroughSubject<String, Never> { get }

    func viewDidLoad()
    func deleteRecord(id: String)
    func editRecord(id: String)
    func addRecordButtonTapped()
    func toggleMetricSwitchTo(_ state: Bool)
    func previousMonthButtonTapped()
    func nextMonthButtonTapped()
}

final class BodyParameterMonitorViewModel: BodyParameterMonitorModuleCoordinatable {
    var headForAddRecord: (() -> Void)?
    var headForEditRecord: ((String) -> Void)?
    
    private(set) var widgetDataPublisher = PassthroughSubject<WidgetModel, Never>()
    private(set) var graphDataPublisher = PassthroughSubject<GraphModel, Never>()
    private(set) var tableDataPublisher = PassthroughSubject<[TableItemModel], Never>()
    private(set) var toastMessage = PassthroughSubject<String, Never>()
    
    private let dataProvider: BodyParameterControlDataProviderProtocol
    private let unitsData: UnitsConvertingData
    private var currentGraphDate = Date()
    private var cancellables: Set<AnyCancellable> = []
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? ""
    }

    private var fetchedRawRecords: [BodyParameterRecord] = [] {
        didSet {
            parseDataUsing(metric: userDefaultsMetric)
        }
    }
    
    private var userDefaultsMetric: Bool {
        get {
            UserDefaults.standard.bool(forKey: "metric")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "metric")
            print(newValue)
        }
    }
    
    init(dataProvider: BodyParameterControlDataProviderProtocol, unitsData: UnitsConvertingData) {
        self.dataProvider = dataProvider
        self.unitsData = unitsData
        setSubscriptions()
    }
}

// MARK: - Private Methods
extension BodyParameterMonitorViewModel {
    func setSubscriptions() {
        dataProvider.contentPublisher
            .sink(receiveValue: { [weak self] event in
                guard let self else { return }
                self.fetchRawRecordsData()
                
                switch event {
                case .inserted: toastMessage.send("Добавлено новое измерение")
                case .deleted: toastMessage.send("Измерение было удалено")
                case .updated: toastMessage.send("Измерение было изменено")
                }
            })
            .store(in: &cancellables)
        
        UserDefaults.standard.publisher(for: \.metric).sink { [weak self] state in
            self?.parseDataUsing(metric: state)
        }
        .store(in: &cancellables)
    }
}

// MARK: - View Model Protocol

extension BodyParameterMonitorViewModel: BodyParameterMonitorViewModelProtocol {
    func toggleMetricSwitchTo(_ state: Bool) {
        userDefaultsMetric = state

    }
    
    func previousMonthButtonTapped() {
        currentGraphDate = self.currentGraphDate.addOrSubtractMonth(month: -1)
        parseDataUsing(metric: userDefaultsMetric)
    }
    
    func nextMonthButtonTapped() {
        currentGraphDate = self.currentGraphDate.addOrSubtractMonth(month: 1)
        parseDataUsing(metric: userDefaultsMetric)
    }
    
    func viewDidLoad() {
        fetchRawRecordsData()
    }
    
    func deleteRecord(id: String) {
        do {
            try dataProvider.deleteRecord(id: id)
        } catch {
            ErrorHandler.shared.handle(error: error)
        }
    }
    
    func editRecord(id: String) {
        headForEditRecord?(id)
    }
    
    func addRecordButtonTapped() {
        headForAddRecord?()
    }
}

// MARK: - Private Methods

private extension BodyParameterMonitorViewModel {
    func fetchRawRecordsData() {
        do {
            fetchedRawRecords = try dataProvider.fetchData()
        } catch {
            ErrorHandler.shared.handle(error: error)
        }
    }

    func parseDataUsing(metric: Bool) {
        let multiplier = metric ? unitsData.metricUnitsMultiplier : unitsData.imperialUnitsMultiplier
        let bodyParameterRecords = fetchedRawRecords.map {
            BodyParameterRecord(id: $0.id, parameter: $0.parameter * multiplier, date: $0.date)
        }
        
        let formattedRecords = formatRecords(metric: metric, bodyParameterRecords)
        
        let widgetData = WidgetModel(primaryValue: formattedRecords.last?.parameter ?? "",
                                     secondaryValue: formattedRecords.last?.delta ?? "",
                                     isMetricOn: userDefaultsMetric)
        
        let graphData = formatGraphData(bodyParameterData: bodyParameterRecords)
        
        let tableData = formattedRecords.reversed().map { item in
            TableItemModel(id: item.id,
                           value: item.parameter,
                           valueDelta: item.delta,
                           date: item.date)
        }
                
        widgetDataPublisher.send(widgetData)
        graphDataPublisher.send(graphData)
        tableDataPublisher.send(tableData)
    }
    
    func formatRecords(metric: Bool, _ records: [BodyParameterRecord]) -> [FormattedRecord] {
        records.enumerated().map { index, record in
            let unitsName = metric ? unitsData.metricUnitsName : unitsData.imperialUnitsName
            let parameter = String(format: "%.1f", record.parameter)
                .replacingOccurrences(of: ".", with: decimalSeparator) + " " + unitsName
            
            var delta: String?
            if index > 0 {
                let difference = records[index].parameter - records[index - 1].parameter
                let differenceString = String(format: "%.1f", difference)
                    .replacingOccurrences(of: ".", with: decimalSeparator) + " " + unitsName
                switch difference {
                case ..<0: delta = differenceString
                case 0: delta = String(0) + " " + unitsName
                default: delta = "+" + differenceString
                }
            }
            
            let date = record.date.toString()
            return FormattedRecord(id: record.id, parameter: parameter, delta: delta ?? "", date: date)
        }
    }
     
    func formatGraphData(bodyParameterData: [BodyParameterRecord]) -> GraphModel {
        let filteredBodyParameterData = bodyParameterData.filter { record in
            record.date.onlyMonthYear() >= currentGraphDate.onlyMonthYear() &&
            record.date.onlyMonthYear() < currentGraphDate.onlyMonthYear().addOrSubtractMonth(month: 1)
        }
        
        let graphData = filteredBodyParameterData.map { item in
            GraphData(id: item.id, value: item.parameter, date: item.date)
        }
        
        let maxDate = (bodyParameterData.map { $0.date }.min() ?? Date()).onlyMonthYear()
        let mixDate = (bodyParameterData.map { $0.date }.max() ?? Date()).onlyMonthYear()
        
        let isPreviousButtonEnabled = currentGraphDate.onlyMonthYear() > maxDate
        let isNextButtonEnabled = currentGraphDate.onlyMonthYear() < mixDate
        
        let graphItem = GraphModel(monthName: currentGraphDate.toString(format: "MMM YYYY"),
                                 isPreviousButtonEnabled: isPreviousButtonEnabled,
                                 isNextButtonEnabled: isNextButtonEnabled,
                                 graphData: graphData)
        return graphItem
    }
}
