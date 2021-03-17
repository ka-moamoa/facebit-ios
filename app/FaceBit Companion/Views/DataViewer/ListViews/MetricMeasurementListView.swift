//
//  MetricMeasurementListView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import SwiftUI
import GRDB

struct MetricMeasurementListView: View {
    @State var latestMetricMeasurement: MetricMeasurement?
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: MetricMeasurement
                            .order(Column("id").desc)
                            .including(optional: MetricMeasurement.event)
                            .asRequest(of: MetricMeasurementDetailed.self)
                ),
                rowBuilder: { m in return MetricMeasurementSummaryView(measurement: m) },
                title: "Metric Measurements"
            ),
            label: {
                Text("Metric Measurements")
            })
    }
}

struct MetricMeasurementListView_Previews: PreviewProvider {
    static var previews: some View {
        MetricMeasurementListView()
    }
}
