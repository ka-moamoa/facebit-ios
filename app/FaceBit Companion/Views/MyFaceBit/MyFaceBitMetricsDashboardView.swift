//
//  MyFaceBitMetricsDashboardView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//
//  @copyright Copyright (c) 2022 Ka Moamoa
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the license.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI

struct MyFaceBitMetricsDashboardView: View {
    @ObservedObject var facebit: FaceBitPeripheral
    @ObservedObject var maskVM: MaskViewModel
    
    
    let gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let widgetHeight: CGFloat = 135.0 + 32.0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            LazyVGrid(columns:gridItemLayout, spacing: 16.0) {
                MaskWearTimeWidget()
                    .frame(height: widgetHeight)
                
                MetricWidget(
                    title: "Heart Rate",
                    unit: "beats per min",
                    dataType: .heartRate,
                    timerInterval: 10
                )
                .frame(height: widgetHeight)
                
                MetricWidget(
                    title: "Respiratory Rate",
                    unit: "breaths per min",
                    dataType: .respiratoryRate,
                    timerInterval: 10
                )
                .frame(height: widgetHeight)
                
//                TimeSeriesGraphWidgetView(
//                    title: "Temperature",
//                    dataType: .temperature,
//                    timerInterval: 1,
//                    rowLimit: 250,
//                    timeOffset: 5
//                )
//                .frame(height: widgetHeight)
//                TimeSeriesGraphWidgetView(
//                    title: "Pressure",
//                    dataType: .pressure,
//                    timerInterval: 1,
//                    rowLimit: 250,
//                    timeOffset: 4
//                )
//                .frame(height: widgetHeight)
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
                .frame(height: widgetHeight)

//                RespiratoryClsWidgetView()
//                    .frame(height: widgetHeight)
                }
            .padding(16.0)
        })
    }
}

struct MyFaceBitMetricsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMetricsDashboardView(
            facebit: FaceBitPeripheral(readChars: []),
            maskVM: MaskViewModel(db: AppDatabase.shared)
        )
            .environmentObject(FaceBitPeripheral(readChars: []))
    }
}
