//
//  MyFaceBitMetricsDashboardView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct MyFaceBitMetricsDashboardView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    private var gridItemLayout = [
        GridItem(.flexible(minimum: 0.0, maximum: 250.0)),
        GridItem(.flexible(minimum: 0.0, maximum: 250.0))
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            GeometryReader { metrics in
                LazyVGrid(columns:gridItemLayout, spacing: 16.0) {
                    TimeSeriesGraphWidgetView(
                        title: "Temperature",
                        dataType: .temperature,
                        timerInterval: 1,
                        rowLimit: 100,
                        timeOffset: 5
                    )
                    .frame(height: (metrics.size.width / 2) - 32.0)
                    TimeSeriesGraphWidgetView(
                        title: "Pressure",
                        dataType: .pressure,
                        timerInterval: 1,
                        rowLimit: 100,
                        timeOffset: 4
                    )
                    .frame(height: (metrics.size.width / 2) - 32.0)
                    TimeSeriesValueWidgetView(
                        title: "Temperature",
                        unit: "Celsius",
                        dataType: .temperature,
                        timerInterval: 2,
                        rowLimit: 1,
                        timeOffset: 4
                    )
                    .frame(height: (metrics.size.width / 2) - 32.0)
                    TimeSeriesValueWidgetView(
                        title: "Pressure",
                        unit: "mBar",
                        dataType: .pressure,
                        timerInterval: 2,
                        rowLimit: 1,
                        timeOffset: 4
                    )
//                    .frame(height: (metrics.size.width / 2) - 32.0)
                }
                .padding()
            }
//            GeometryReader { geometry in
//                VStack {
//                    HStack {
//                        TimeSeriesGraphWidgetView(title: "Pressure", series: [])
//                        TimeSeriesGraphWidgetView(title: "Temperature", series: [])
//                    }
//                    HStack {
//                        ValueWidgetView(
//                            title: "Pressure",
//                            unit: "bar",
//                            value: 0.0
//                        )
//                        ValueWidgetView(
//                            title: "Temperature",
//                            unit: "celsius",
//                            value: 0.0
//                        )
//                    }
//                }
//                .padding()
//                .frame(width: geometry.size.width, height: geometry.size.width)
            })
//        })
    }
}

struct MyFaceBitMetricsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMetricsDashboardView()
    }
}
