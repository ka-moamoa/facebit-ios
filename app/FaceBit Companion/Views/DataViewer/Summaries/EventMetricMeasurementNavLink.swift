//
//  EventMetricMeasurementNavLink.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import SwiftUI
import GRDB

struct EventMetricMeasurementNavLink: View {
    var event: Event
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: MetricMeasurement
                        .filter(MetricMeasurement.Columns.eventId == event.id)
                        .including(required: MetricMeasurement.event)
                        .asRequest(of: MetricMeasurementDetailed.self)
                ),
                rowBuilder: { info in
                    return MetricMeasurementSummaryView(measurement: info)
                },
                title: "Metric Measurements"
            ),
            label: {
                Text("Metric Measurements")
            }
        )
    }
}

struct EventMetricMeasurementNavLink_Previews: PreviewProvider {
    static var previews: some View {
        EventMetricMeasurementNavLink(
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
