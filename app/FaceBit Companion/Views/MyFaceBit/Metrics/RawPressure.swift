//
//  RawPressure.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct RawPressure: View, MetricDashboardView {
    @ObservedObject var facebit: FaceBitPeripheral
    
    var body: some View {
        VStack {
            Text("Pressure")
            LiveLinePlot(timeSeries: $facebit.PressureReadings, showAxis: false)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10.0)
                .stroke(lineWidth: 1.0)
        )
    }
}

struct RawPressure_Previews: PreviewProvider {
    
    static var previews: some View {
        RawPressure(facebit: FaceBitPeripheral())
    }
}
