//
//  EventTimeSeriesMeasurementNavLink.swift
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
