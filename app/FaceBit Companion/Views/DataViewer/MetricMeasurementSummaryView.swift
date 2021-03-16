//
//  MetricMeasurementSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI

struct MetricMeasurementSummaryView: View {
    var metricMeasurement: MetricMeasurement
    
    
    var body: some View {
        Text("\(metricMeasurement.date)")
        
    }
}

struct MetricMeasurementSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        MetricMeasurementSummaryView(
            metricMeasurement: MetricMeasurement(
                id: nil,
                value: 101.1,
                dataType: .heartRate,
                timestamp: 12345,
                date: Date(),
                eventId: nil
            )
        )
    }
}
