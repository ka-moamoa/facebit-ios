//
//  RawTemperature.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct RawTemperature: View, MetricDashboardView {
    @ObservedObject var facebit: FaceBitPeripheral
    
    var body: some View {
        VStack {
            Text("Raw Temperature")
            LiveLinePlot(timeSeries: $facebit.TemperatureReadings, showAxis: false)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10.0)
                .stroke(lineWidth: 1.0)
        )
    }
}

struct RawTemperature_Previews: PreviewProvider {
    
    static var previews: some View {
        RawTemperature(facebit: FaceBitPeripheral())
    }
}
