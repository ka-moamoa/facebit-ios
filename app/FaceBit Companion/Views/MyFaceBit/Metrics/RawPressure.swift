//
//  RawPressure.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct RawPressure: View {
    @Binding var pressureReadings: [TimeSeriesMeasurement]
    
    var body: some View {
        VStack {
            Text("Pressure")
            LiveLinePlot(timeSeries: $pressureReadings, showAxis: false)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10.0)
                .stroke(lineWidth: 1.0)
        )
    }
}

struct RawPressure_Previews: PreviewProvider {
    @State static var pressureReadings: [TimeSeriesMeasurement] = [
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
        RawPressure(pressureReadings: $pressureReadings)
    }
}
