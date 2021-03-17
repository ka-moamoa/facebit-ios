//
//  EventTimeSeriesMeasurementNavLink.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import SwiftUI
import GRDB

struct EventTimeSeriesMeasurementNavLink: View {
    var event: Event
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: TimeSeriesMeasurement
                        .filter(TimeSeriesMeasurement.Columns.eventId == event.id)
                        .including(required: TimeSeriesMeasurement.dataRead)
                        .including(required: TimeSeriesMeasurement.event)
                        .asRequest(of: TimeSeriesMeasurementDetailed.self)
                ),
                rowBuilder: { info in
                    return TimeSeriesMeasurementSummaryView(measurement: info)
                },
                title: "Time Series Measurements"
            ),
            label: {
                Text("Time Series Measurements")
            }
        )
    }
}

struct EventTimeSeriesMeasurementNavLink_Previews: PreviewProvider {
    static var previews: some View {
        EventTimeSeriesMeasurementNavLink(
            event: Event(
                id: 0,
                eventType: .cough,
                otherEventLabel: nil,
                notes: nil,
                startDate: Date(),
                endDate: nil
            )
        )
    }
}
