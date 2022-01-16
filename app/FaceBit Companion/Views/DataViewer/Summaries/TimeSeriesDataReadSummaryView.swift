//
//  DataReadSummaryView.swift
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
                numSamples: 100,
                eventId: nil
            )
        )
    }
}
