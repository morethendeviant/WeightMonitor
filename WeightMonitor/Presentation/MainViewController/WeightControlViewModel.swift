//
//  WeightControlViewModel.swift
//  WeightMonitor
//
//  Created by Aleksandr Velikanov on 04.05.2023.
//

import Foundation
import Combine

protocol WeightControlViewModelProtocol {
    func viewDidLoad()
    
    //var sectionsData: [SectionData] { get }
    var sectionDataPublisher: Published<[SectionData]>.Publisher { get }
}

final class WeightControlViewModel {
    
    let widgetData = SectionData(key: .widget,
                                   values: [.widgetCell(WidgetItem(widgetTitle: "Текущий вес",
                                                                   primaryValue: "82.5 кг",
                                                                   secondaryValue: "-0.5 кг",
                                                                   isMetricOn: true))])
    
    let graphData = SectionData(key: .graph, values: [.graphCell(GraphItem(selectedMonth: 0,
                                                                           value: "",
                                                                           date: ""))])
    
    let historyData = SectionData(key: .table, values: [.tableCell(TableItem(value: "82.5 кг",
                                                                             valueDelta: "-0.5 кг",
                                                                             date: "2 мар")),
                                                        .tableCell(TableItem(value: "80.0 кг",
                                                                             valueDelta: "+2.5 кг",
                                                                             date: "30 апр"))])
    
    @Published var sectionsData: [SectionData] = []
    
    init() {
        
        
    }
}

extension WeightControlViewModel: WeightControlViewModelProtocol {
    var sectionDataPublisher: Published<[SectionData]>.Publisher {
        $sectionsData
    }

    
    func viewDidLoad() {
        sectionsData = [widgetData, graphData, historyData]
    }
    
}
