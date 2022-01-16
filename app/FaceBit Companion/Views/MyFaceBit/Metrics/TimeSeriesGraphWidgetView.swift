//
//  RawPressure.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
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

struct TimeSeriesGraphWidgetView: View {
    var title: String
    @ObservedObject var publisher: TimeSeriesMeasurementViewModel
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(title: String, dataType: TimeSeriesDataRead.DataType, timerInterval: TimeInterval, rowLimit: Int, timeOffset: TimeInterval) {
        
        self.title = title
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
                LiveLinePlot(timeSeries: $publisher.items, showAxis: false)
            }
        }
    }
}

struct RawPressure_Previews: PreviewProvider {
    
    static var previews: some View {
        TimeSeriesGraphWidgetView(
            title: "Time Series",
            dataType: .temperature,
            timerInterval: 1,
            rowLimit: 25,
            timeOffset: 2
        )
    }
}
