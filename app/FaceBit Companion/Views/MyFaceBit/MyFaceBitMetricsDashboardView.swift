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
            }
        })
    }
}

struct MyFaceBitMetricsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMetricsDashboardView()
    }
}
