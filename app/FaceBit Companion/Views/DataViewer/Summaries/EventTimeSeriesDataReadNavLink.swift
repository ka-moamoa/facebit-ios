//
//  EventTimeSeriesMeasurementNavLink.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import SwiftUI
import GRDB

struct EventTimeSeriesDataReadNavLink: View {
    var event: Event
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: TimeSeriesDataRead
                        .filter(TimeSeriesDataRead.Columns.eventId == event.id)
                        .including(all: TimeSeriesDataRead.measurements)
                        .including(optional: TimeSeriesDataRead.event)
                        .asRequest(of: TimeSeriesDataReadDetailed.self)
                ),
                rowBuilder: { info in
                    return TimeSeriesDataReadSummaryView(dataRead: info.dataRead)
                },
                title: "Time Series Data"
            ),
            label: {
                Text("Time Series Data")
            }
        )
    }
}

struct EventTimeSeriesMeasurementNavLink_Previews: PreviewProvider {
    static var previews: some View {
        EventTimeSeriesDataReadNavLink(
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
    }
}
