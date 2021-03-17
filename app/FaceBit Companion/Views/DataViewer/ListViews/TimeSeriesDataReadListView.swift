//
//  TimeSeriesDataReadListView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import SwiftUI
import GRDB

struct TimeSeriesDataReadListView: View {
    @State var latestDataRead: TimeSeriesDataRead?
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: TimeSeriesDataRead.order(Column("id").desc)
                ),
                rowBuilder: { dr in return TimeSeriesDataReadSummaryView(dataRead: dr) },
                title: "Time Series Data Reads"
            ),
            label: {
                Text("TimeSeries Data Read")
            })
    }
}

struct TimeSeriesDataReadListView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSeriesDataReadListView()
    }
}
