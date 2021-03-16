//
//  DatabaseLoggerView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI

struct DatabaseViewerView: View {
    @ObservedObject var viewModel: DataViewerViewModel
    
    var body: some View {
        List() {
            NavigationLink(
                destination: Text("TODO: List of Timestamps"),
                label: {
                    if let ts = viewModel.latestTimestamp {
                        TimestampSummaryView(timestamp: ts)
                    } else {
                        Text("No Timestamp Records")
                    }
                }
            )
        
            if let event = viewModel.activeEvent {
                EventSummaryView(event: event)
            } else {
                Text("No Active Event")
            }
            
            if let dataRead = viewModel.latestTimeSeriesDataRead {
                TimeSeriesDataReadSummaryView(dataRead: dataRead)
            } else {
                Text("No Time Series Data Reads")
            }
            
            if let metric = viewModel.latestMetricMeasurement {
                MetricMeasurementSummaryView(metricMeasurement: metric)
            } else {
                Text("No Metric Measurements")
            }
        }
        .navigationTitle("Data Viewer")
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
