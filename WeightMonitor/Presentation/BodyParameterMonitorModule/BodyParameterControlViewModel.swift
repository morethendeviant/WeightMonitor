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
    
    var headForAddRecord: (() -> Void)?
    
    private let dataProvider: BodyParameterDataProviderProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(dataProvider: BodyParameterDataProviderProtocol) {
        self.dataProvider = dataProvider
    }
}

extension BodyParameterControlViewModel: BodyParameterControlViewModelProtocol {
    var sectionDataPublisher: Published<[SectionData]>.Publisher {
        $sectionsData
    }
    
    func viewDidLoad() {
        dataProvider.contentPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.fetchData()
            })
            .store(in: &cancellables)
        
        fetchData()
    }
    
    func deleteRecord(id: String) {
        try? dataProvider.deleteRecord(id: id)
    }
 
    func addRecordButtonTapped() {
        headForAddRecord?()
    }
}

private extension BodyParameterControlViewModel {
    func formatRecords(_ records: [BodyParameterRecord]) -> [FormattedRecord] {
        records.enumerated().map { index, record in
            let parameter = String(format: "%.1f", record.parameter) + " кг"
            var delta: String?
            if index > 0 {
                let difference = records[index].parameter - records[index - 1].parameter
                let differenceString = String(format: "%.1f", difference) + " кг"
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
    
    func fetchData() {
        guard let weightData = try? dataProvider.fetchData() else { return }
        
        let parameterRecords = formatRecords(weightData)
        
        let widgetItem = WidgetItem(widgetTitle: "Текущий вес",
                                    primaryValue: parameterRecords.last?.parameter ?? "",
                                    secondaryValue: parameterRecords.last?.delta ?? "",
                                    isMetricOn: true)
        
        let widgetData = SectionData(key: .widget,
                                     values: [.widgetCell(widgetItem)])
        
        let graphData = SectionData(key: .graph,
                                    values: [.graphCell(GraphItem(selectedMonth: 0,
                                                                  value: "",
                                                                  date: ""))])
        
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
