//
//  DatabaseLoggerView.swift
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

struct DatabaseViewerView: View {
    @ObservedObject var viewModel: DataViewerViewModel
    
    var body: some View {
        List() {
            TimestampListView(latestTimestamp: viewModel.latestTimestamp)
            EventListView(activeEvent: viewModel.activeEvent)
            TimeSeriesDataReadListView(latestDataRead: viewModel.latestTimeSeriesDataRead)
            MetricMeasurementListView(latestMetricMeasurement: viewModel.latestMetricMeasurement)
        }
        .navigationTitle("Data Viewer")
        .navigationBarItems(trailing:
            FaceBitConnectionStatusButtonView()
        )
    }
}

struct DatabaseLoggerView_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseViewerView(
            viewModel: DataViewerViewModel(
                appDatabase: AppDatabase.shared,
                facebit: FaceBitPeripheral(readChars: [])
            )
        )
    }
}
