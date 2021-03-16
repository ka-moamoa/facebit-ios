//
//  TimeSeriesValueWidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/2/21.
//

import SwiftUI

struct TimeSeriesValueWidgetView: View {
    private var title: String
    private var unit: String
    @ObservedObject var publisher: TimeSeriesMeasurementViewModel
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(
        title: String,
        unit: String,
        dataType: TimeSeriesDataRead.DataType,
        timerInterval: TimeInterval,
        rowLimit: Int,
        timeOffset: TimeInterval
    ) {
        
        self.title = title
        self.unit = unit
        self.publisher = TimeSeriesMeasurementViewModel(
            appDatabase: AppDatabase.shared,
            dataType: dataType,
            rowLimit: rowLimit,
            timeOffset: timeOffset
        )
    }
    
    var body: some View {
        WidgetView {
            VStack {
                Text(title)
                    .bold()
                Spacer()
                Text("\(String(format: "%.2f", publisher.items.first?.timeseriesMeasurement.value ?? 0.0))")
                    .font(.system(size: 32.0))
                Spacer()
                Text(unit)
            }
        }
    }
}

struct TimeSeriesValueWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSeriesValueWidgetView(
            title: "Time Series",
            unit: "Units",
            dataType: .temperature,
            timerInterval: 1,
            rowLimit: 25,
            timeOffset: 2
        )
    }
}
