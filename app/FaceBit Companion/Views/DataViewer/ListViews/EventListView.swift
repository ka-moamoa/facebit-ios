//
//  EventListView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

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
