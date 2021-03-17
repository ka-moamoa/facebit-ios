//
//  TimestampListView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI

struct TimestampListView: View {
    @State var latestTimestamp: Timestamp?
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: Timestamp.all()
                ),
                rowBuilder: { ts in TimestampSummaryView(timestamp: ts) },
                title: "Timestamps"
            ),
            label: {
                Text("Timestamps")
            }
        )
    }
}

struct TimestampListView_Previews: PreviewProvider {
    static var previews: some View {
        TimestampListView(
            latestTimestamp: Timestamp(id: 0, dataType: .peripheralSync, date: Date()))
    }
}
