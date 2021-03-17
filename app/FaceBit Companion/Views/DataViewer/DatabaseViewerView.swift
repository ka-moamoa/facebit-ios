//
//  DatabaseLoggerView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

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
