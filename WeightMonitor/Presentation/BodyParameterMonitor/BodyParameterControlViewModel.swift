//
//  WeightControlViewModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation
import Combine

protocol BodyParameterControlModuleCoordinatable {
    var headForAddRecord: (() -> Void)? { get set }
    var headForEditRecord: ((String) -> Void)? { get set }
}

protocol BodyParameterControlViewModelProtocol {
    var sectionDataPublisher: Published<[SectionData]>.Publisher { get }
    var toastMessage: PassthroughSubject<String, Never> { get }

    func viewDidLoad()
    func deleteRecord(id: String)
    func editRecord(id: String)
    func addRecordButtonTapped()
}

final class BodyParameterControlViewModel: BodyParameterControlModuleCoordinatable {
    var headForAddRecord: (() -> Void)?
    var headForEditRecord: ((String) -> Void)?
    
    @Published private(set) var sectionsData: [SectionData] = []
    private(set) var metricSwitchToggled = PassthroughSubject<Bool, Never>()
    private(set) var toastMessage = PassthroughSubject<String, Never>()
    
    private let dataProvider: BodyParameterControlDataProviderProtocol
    private let unitsData: UnitsConvertingData
    private var cancellables: Set<AnyCancellable> = []
    private var userDefaultsMetric: Bool {
        get {
            UserDefaults.standard.bool(forKey: "metric")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "metric")
        }
    }
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? ""
    }
    
    init(dataProvider: BodyParameterControlDataProviderProtocol, unitsData: UnitsConvertingData) {
        self.dataProvider = dataProvider
        self.unitsData = unitsData
        dataProvider.contentPublisher
            .sink(receiveValue: { [weak self] event in
                guard let self else { return }
                self.fetchData(metric: self.userDefaultsMetric)
                
                switch event {
                case .inserted: toastMessage.send("Добавлено новое измерение")
                case .deleted: toastMessage.send("Измерение было удалено")
                case .updated: toastMessage.send("Измерение было изменено")
                }
            })
            .store(in: &cancellables)
        
        metricSwitchToggled.sink { [weak self] state in
            self?.userDefaultsMetric = state
        }
        .store(in: &cancellables)
        
        UserDefaults.standard.publisher(for: \.metric).sink { [weak self] state in
            self?.fetchData(metric: state)
        }
        .store(in: &cancellables)
    }
}

// MARK: - View Model Protocol

extension BodyParameterControlViewModel: BodyParameterControlViewModelProtocol {
    var sectionDataPublisher: Published<[SectionData]>.Publisher {
        $sectionsData
    }
    
    func viewDidLoad() {
        fetchData(metric: userDefaultsMetric)
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

private extension BodyParameterControlViewModel {
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
    
    func fetchData(metric: Bool) {
        let multiplier = metric ? unitsData.metricUnitsMultiplier : unitsData.imperialUnitsMultiplier
        do {
            let weightData = try dataProvider.fetchData()
            let parameterRecords = formatRecords(metric: metric,
                                                 weightData.map { BodyParameterRecord(id: $0.id,
                                                                                      parameter: $0.parameter*multiplier,
                                                                                      date: $0.date)})
            let widgetItem = WidgetItem(primaryValue: parameterRecords.last?.parameter ?? "",
                                        secondaryValue: parameterRecords.last?.delta ?? "",
                                        isMetricOn: userDefaultsMetric,
                                        metricSwitchPublisher: metricSwitchToggled)
            let widgetData = SectionData(key: .widget,
                                         values: [.widgetCell(widgetItem)])
            let graphData = SectionData(key: .graph,
                                        values: [.graphCell(GraphItem(monthName: "Май",
                                                                      isPreviousButtonEnabled: true,
                                                                      isNextButtonEnabled: false,
                                                                      graphData: []))])
            let historyItems = parameterRecords.reversed().map { item in
                let tableItem = TableItem(id: item.id,
                                          value: item.parameter,
                                          valueDelta: item.delta,
                                          date: item.date)
                return SectionItem.tableCell(tableItem)
            }
            
            let historyData = SectionData(key: .table, values: historyItems)
            sectionsData = [widgetData, graphData, historyData]
        } catch {
            ErrorHandler.shared.handle(error: error)
        }
    }
}
