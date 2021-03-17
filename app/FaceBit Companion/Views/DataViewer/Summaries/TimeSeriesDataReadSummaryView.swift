//
//  DataReadSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI
import GRDB

struct TimeSeriesDataReadSummaryView: View {
    var dataRead: TimeSeriesDataRead
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: TimeSeriesMeasurement
                        .filter(TimeSeriesMeasurement.Columns.dataReadId == dataRead.id)
                        .including(required: TimeSeriesMeasurement.dataRead)
                        .including(optional: TimeSeriesMeasurement.event)
                        .asRequest(of: TimeSeriesMeasurementDetailed.self)
                ),
                rowBuilder: { info in
                    return TimeSeriesMeasurementSummaryView(measurement: info)
                },
                title: "Time Series Measurements"
            ),
            label: {
                dataSummaryView
            }
        )
    }
    
    var dataSummaryView: some View {
        VStack(alignment: .leading) {
            DataSummaryFieldView(
                title: "Id",
                value: "\(dataRead.id ?? -1)"
            )
            
            DataSummaryFieldView(
                title: "Data Type",
                value: "\(dataRead.dataType.rawValue)"
            )
            
            DataSummaryFieldView(
                title: "Frequency",
                value: "\(dataRead.frequency)"
            )
            
            DataSummaryFieldView(
                title: "Millisecond Offset",
                value: "\(dataRead.millisecondOffset)"
            )
            
            DataSummaryFieldView(
                title: "Number of Samples",
                value: "\(dataRead.numSamples)"
            )
            
            DataSummaryFieldView(
                title: "Date",
                value: "\(dataRead.startTime)"
            )
        }
    }
}

struct DataReadSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSeriesDataReadSummaryView(
            dataRead: TimeSeriesDataRead(
                id: nil,
                dataType: .pressure,
                frequency: 25.0,
                millisecondOffset: 100,
                startTime: Date(),
                numSamples: 100
            )
        )
    }
}
