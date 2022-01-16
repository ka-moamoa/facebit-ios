//
//  EventMetricMeasurementNavLink.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
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
