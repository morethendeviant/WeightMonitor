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
}

protocol BodyParameterControlViewModelProtocol {
    var sectionDataPublisher: Published<[SectionData]>.Publisher { get }
    
    func viewDidLoad()
    func deleteRecord(id: String)
    func addRecordButtonTapped()
}

final class BodyParameterControlViewModel: BodyParameterControlModuleCoordinatable {
    @Published var sectionsData: [SectionData] = []
    
    var metricSwitchToggled = PassthroughSubject<Bool, Never>()
    var headForAddRecord: (() -> Void)?
    
    private let dataProvider: BodyParameterDataProviderProtocol
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
    
    init(dataProvider: BodyParameterDataProviderProtocol, unitsData: UnitsConvertingData) {
        self.dataProvider = dataProvider
        self.unitsData = unitsData
        dataProvider.contentPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.fetchData(metric: self.userDefaultsMetric)
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

extension BodyParameterControlViewModel: BodyParameterControlViewModelProtocol {
    var sectionDataPublisher: Published<[SectionData]>.Publisher {
        $sectionsData
    }
    
    func viewDidLoad() {
        fetchData(metric: userDefaultsMetric)
    }
    
    func deleteRecord(id: String) {
        try? dataProvider.deleteRecord(id: id)
    }
    
    func addRecordButtonTapped() {
        headForAddRecord?()
    }
}

private extension BodyParameterControlViewModel {
    func formatRecords(metric: Bool, _ records: [BodyParameterRecord]) -> [FormattedRecord] {
        records.enumerated().map { index, record in
            let unitsName = metric ? unitsData.metricUnitsName : unitsData.imperialUnitsName
            let parameter = String(format: "%.1f", record.parameter) + " " + unitsName
            var delta: String?
            if index > 0 {
                let difference = records[index].parameter - records[index - 1].parameter
                let differenceString = String(format: "%.1f", difference) + " " + unitsName
                switch difference {
                case ..<0: delta = differenceString
                case 0: delta = String(0) + " кг"
                default: delta = "+" + differenceString
                }
            }
            
            let date = record.date.toString()
            return FormattedRecord(id: record.id, parameter: parameter, delta: delta ?? "", date: date)
        }
    }
    
    func fetchData(metric: Bool) {
        let multiplier = metric ? unitsData.metricUnitsMultiplier : unitsData.imperialUnitsMultiplier
        guard let weightData = try? dataProvider.fetchData() else { return }
        
        let parameterRecords = formatRecords(metric: metric, weightData.map { Record(id: $0.id,
                                                                                     parameter: $0.parameter*multiplier,
                                                                                     date: $0.date)
        })
        
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
    }
}
