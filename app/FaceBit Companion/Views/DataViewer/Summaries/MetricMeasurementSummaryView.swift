//
//  MetricMeasurementSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//
//  @copyright Copyright (c) 2022 Ka Moamoa
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the license.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
                    eventName: "test event",
                    eventType: .stationary,
                    maskType: .other,
                    otherEventLabel: nil,
                    notes: nil,
                    startDate: Date(),
                    endDate: nil
                )
            )
        )
    }
}
