//
//  MyFaceBitMetricsDashboardView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct MyFaceBitMetricsDashboardView: View {
    @ObservedObject var facebit: FaceBitPeripheral
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            GeometryReader { geometry in
                
                VStack {
                    HStack {
                        RawPressure(facebit: facebit)
                        RawTemperature(facebit: facebit)
                    }
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.width / 2)
                }
                
            }
        })
    }
}

struct MyFaceBitMetricsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMetricsDashboardView(facebit: FaceBitPeripheral())
    }
}
