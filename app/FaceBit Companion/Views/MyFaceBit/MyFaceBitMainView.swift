//
//  MyFaceBitMainView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/19/21.
//

import SwiftUI
import Combine

struct MyFaceBitMainViewMacOS: View {
    @ObservedObject var facebit: FaceBitPeripheral

    
    var body: some View {
        NavigationView {
            VStack {
                
                HStack {
                    Spacer()
                    Text("FaceBit Device State")
                        .font(.system(.headline))
                    Text(facebit.state.rawValue)
                        Spacer()
                        NavigationLink(
                            destination: EventRecorderView(facebit: facebit),
                            label: {
                                Text("Record Event")
                            }
                        )
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                if facebit.state == .connected {
                    Divider()
                    
                    HStack {
                        Spacer()
                        Text("Live Pressure Reading")
                        Spacer()
                        Text("Current: \(facebit.latestPressure)")
                            .font(.body)
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        LiveLinePlot(
                            timeSeries: $facebit.PressureReadings,
                            showAxis: false,
                            maxTicks: 50
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height / 4.0,
                            alignment: .leading
                        )
                        .cornerRadius(10.0)
                        .padding(16)
                    }
                    
                    Divider()
                    
                    HStack {
                        Spacer()
                        Text("Live Temperature Reading")
                        Spacer()
                        Text("Current: \(facebit.latestTemperature)")
                            .font(.body)
                        Spacer()
                    }
                        
                    GeometryReader { geometry in
                        LiveLinePlot(
                            timeSeries: $facebit.TemperatureReadings,
                            showAxis: false,
                            maxTicks: 50
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height / 4.0,
                            alignment: .leading
                        )
                        .cornerRadius(10.0)
                        .padding(16)
                    }
                    
                }
            
            }
            .onAppear(perform: searchForFaceBit)
            .navigationBarTitle("My FaceBit", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(minWidth: 800, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
    }
    
    private func searchForFaceBit() {
        print("searching")
        BluetoothConnectionManager
            .shared
            .searchFor(peripheral: facebit)
    }
}

struct MyFaceBitMainViewMacOS_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMainViewMacOS(facebit: FaceBitPeripheral())
    }
}
