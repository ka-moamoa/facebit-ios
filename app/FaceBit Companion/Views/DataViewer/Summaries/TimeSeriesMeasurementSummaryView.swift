//
//  TimeSeriesMeasurementSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import SwiftUI

struct TimeSeriesMeasurementSummaryView: View {
    var measurement: TimeSeriesMeasurementDetailed
    
    var body: some View {
        VStack(alignment: .leading) {
            DataSummaryFieldView(
                title: "Id",
                value: "\(measurement.id ?? -1)"
            )
            
            DataSummaryFieldView(
                title: "Data Type",
                value: "\(measurement.dataRead.dataType)"
            )
            
            DataSummaryFieldView(
                title: "Value",
                value: "\(measurement.timeSeriesMeasurement.value)"
            )
            
            DataSummaryFieldView(
                title: "Date",
                value: "\(measurement.timeSeriesMeasurement.date)"
            )
            
            if let event = measurement.event {
            
                DataSummaryFieldView(
                    title: "Event Type",
                    value: "\(event.eventType.rawValue)"
                )
            }
        }
    }
}

struct TimeSeriesMeasurementSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSeriesMeasurementSummaryView(
            measurement: TimeSeriesMeasurementDetailed(
                timeSeriesMeasurement: TimeSeriesMeasurement(
                    id: 0,
                    value: 10.0,
                    date: Date(),
                    dataReadId: 0,
                    eventId: nil),
                dataRead: TimeSeriesDataRead(
                    id: 0,
                    dataType: .pressure,
                    frequency: 20,
                    millisecondOffset: 100,
                    startTime: Date(),
                    numSamples: 100,
                    eventId: nil
                ),
                event: nil)
        )
    }
}
