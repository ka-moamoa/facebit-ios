//
//  MyFaceBitMetricsDashboardView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct MyFaceBitMetricsDashboardView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            GeometryReader { geometry in
                VStack {
                    HStack {
                        TimeSeriesGraphWidgetView(title: "Pressure", series: $facebit.PressureReadings)
                        TimeSeriesGraphWidgetView(title: "Temperature", series: $facebit.TemperatureReadings)
                    }
                    HStack {
                        ValueWidgetView(
                            title: "Pressure",
                            unit: "bar",
                            value: $facebit.latestPressure
                        )
                        ValueWidgetView(
                            title: "Temperature",
                            unit: "celsius",
                            value: $facebit.latestTemperature
                        )
                    }
                }
                .padding()
                .frame(width: geometry.size.width, height: geometry.size.width)
            }
        })
    }
}

struct MyFaceBitMetricsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMetricsDashboardView()
    }
}
