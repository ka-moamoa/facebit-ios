//
//  TimeSeriesMeasurementSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
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
