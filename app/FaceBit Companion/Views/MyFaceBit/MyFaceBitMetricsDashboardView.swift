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
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private let widgetHeight: CGFloat = 135.0 + 32.0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            LazyVGrid(columns:gridItemLayout, spacing: 16.0) {
                TimeSeriesGraphWidgetView(
                    title: "Temperature",
                    dataType: .temperature,
                    timerInterval: 1,
                    rowLimit: 100,
                    timeOffset: 5
                )
                .frame(height: widgetHeight)
                TimeSeriesGraphWidgetView(
                    title: "Pressure",
                    dataType: .pressure,
                    timerInterval: 1,
                    rowLimit: 100,
                    timeOffset: 4
                )
                .frame(height: widgetHeight)
                TimeSeriesValueWidgetView(
                    title: "Temperature",
                    unit: "Celsius",
                    dataType: .temperature,
                    timerInterval: 2,
                    rowLimit: 1,
                    timeOffset: 4
                )
                .frame(height: widgetHeight)
                TimeSeriesValueWidgetView(
                    title: "Pressure",
                    unit: "mBar",
                    dataType: .pressure,
                    timerInterval: 2,
                    rowLimit: 1,
                    timeOffset: 4
                )
                RespiratoryClsWidgetView()
                    .frame(height: widgetHeight)
                }
                .padding()
        })
    }
}

struct MyFaceBitMetricsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMetricsDashboardView()
    }
}
