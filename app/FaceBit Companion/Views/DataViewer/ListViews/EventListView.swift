//
//  EventListView.swift
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

struct EventListView: View {
    @State var activeEvent: Event?
    
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: Event.order(Column("id").desc)
                ),
                rowBuilder: { e in
                    return Group {
                        EventSummaryView(event: e)
                        EventTimeSeriesDataReadNavLink(event: e)
                            .padding(.leading, 32.0)
                        EventMetricMeasurementNavLink(event: e)
                            .padding(.leading, 32.0)
                        EventExportButton(event: e)
                            .padding(.leading, 32.0)
                    }
                },
                title: "Events"
            ),
            label: {
                Text("Events")
            }
        )
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
