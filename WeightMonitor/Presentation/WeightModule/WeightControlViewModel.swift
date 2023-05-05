//
//  WeightControlViewModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation
import Combine

protocol WeightControlViewModelProtocol {
    var sectionDataPublisher: Published<[SectionData]>.Publisher { get }
    
    func viewDidLoad()
    func addRecord()
    func deleteRecord(id: String)
}



final class WeightControlViewModel {
    @Published var sectionsData: [SectionData] = []
    
    private var cancellables: Set<AnyCancellable> = []

    private let dataProvider: WeightDataProviderProtocol
    
    init(dataProvider: WeightDataProviderProtocol) {
        self.dataProvider = dataProvider
    }
}

extension WeightControlViewModel: WeightControlViewModelProtocol {
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
    
    func addRecord() {
        try? dataProvider.addRecord(Record(id: UUID().uuidString, weight: Double(Int.random(in: 50...100)), date: Date()))
    }
    
    func deleteRecord(id: String) {
        try? dataProvider.deleteRecord(id: id)
        print(id)
    }
}


private extension WeightControlViewModel {
    func formatRecords(_ records: [WeightRecord]) -> [(id: String, weight: String, delta: String, date: String)] {
        records.enumerated().map { index, record in
            let weight = String(format: "%.1f", record.weight) + " кг"
            var delta: String?
            if index > 0 {
                let difference = records[index].weight - records[index - 1].weight
                let differenceString = String(format: "%.1f", difference) + " кг"
                switch difference {
                    case ..<0: delta = differenceString
                case 0: delta = String(0) + " кг"
                default: delta = "+" + differenceString
                }
            }
            
            let date = record.date.toString()
            return (id: record.id, weight: weight, delta: delta ?? "", date: date)
        }
    }
    
    func fetchData() {
        let weightRecords = formatRecords(try! dataProvider.fetchWeightData())
        
        let widgetItem = WidgetItem(widgetTitle: "Текущий вес",
                                    primaryValue: weightRecords.last?.weight ?? "",
                                    secondaryValue: weightRecords.last?.delta ?? "",
                                    isMetricOn: true)
        
        let widgetData = SectionData(key: .widget,
                                     values: [.widgetCell(widgetItem)])
        
        let graphData = SectionData(key: .graph, values: [.graphCell(GraphItem(selectedMonth: 0,
                                                                               value: "",
                                                                               date: ""))])
        
        let historyItems = weightRecords.reversed().map { item in
            let tableItem = TableItem(id: item.id, value: item.weight, valueDelta: item.delta, date: item.date)
            return SectionItem.tableCell(tableItem)
        }
            
        let historyData = SectionData(key: .table, values: historyItems)
        sectionsData = [widgetData, graphData, historyData]
    }
    
}
