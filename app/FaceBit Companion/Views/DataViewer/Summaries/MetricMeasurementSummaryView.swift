//
//  MetricMeasurementSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI

struct MetricMeasurementSummaryView: View {
    var measurement: MetricMeasurementDetailed
    
    
    var body: some View {
        VStack(alignment: .leading) {
            DataSummaryFieldView(
                title: "Id",
                value: "\(measurement.id ?? -1)"
            )
            
            DataSummaryFieldView(
                title: "Data Type",
                value: "\(measurement.metric.dataType.rawValue)"
            )
            
            DataSummaryFieldView(
                title: "Value",
                value: "\(measurement.metric.value)"
            )
            
            DataSummaryFieldView(
                title: "timestamp",
                value: "\(measurement.metric.timestamp)"
            )
            
            DataSummaryFieldView(
                title: "date",
                value: "\(measurement.metric.date)"
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

struct MetricMeasurementSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        MetricMeasurementSummaryView(
            measurement: MetricMeasurementDetailed(
                metric: MetricMeasurement(
                    id: nil,
                    value: 101.1,
                    dataType: .heartRate,
                    timestamp: 12345,
                    date: Date(),
                    eventId: nil
                ),
                event: Event(
                    id: 0,
                    eventType: .normalBreathing,
                    otherEventLabel: nil,
                    notes: nil,
                    startDate: Date(),
                    endDate: nil)
            )
        )
    }
}
