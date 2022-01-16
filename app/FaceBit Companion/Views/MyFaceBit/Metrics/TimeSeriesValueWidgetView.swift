//
//  TimeSeriesValueWidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/2/21.
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
                Text("\(String(format: "%.2f", publisher.items.first?.timeSeriesMeasurement.value ?? 0.0))")
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
