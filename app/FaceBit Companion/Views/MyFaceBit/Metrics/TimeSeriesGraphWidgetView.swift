//
//  RawPressure.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct TimeSeriesGraphWidgetView: View {
    @State var title: String
    @Binding var series: [TimeSeriesMeasurement]
    
    var body: some View {
        WidgetView {
            VStack {
                Text(title)
                    .bold()
                LiveLinePlot(timeSeries: $series, showAxis: false)
            }
        }
    }
}

struct RawPressure_Previews: PreviewProvider {
    @State static var timeSeries = [
        TimeSeriesMeasurement(value: 10.0, date: Date(), type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 10, type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 20, type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 30, type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 40, type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 50, type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 60, type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 70, type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 80, type: .pressure),
        TimeSeriesMeasurement(value: 10.0, date: Date() + 90, type: .pressure)
    ]
    
    static var previews: some View {
        TimeSeriesGraphWidgetView(title: "Time Series", series: $timeSeries)
    }
}
