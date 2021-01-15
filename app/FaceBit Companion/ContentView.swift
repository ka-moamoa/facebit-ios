//
//  ContentView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bluetoothManager: BluetoothConnectionManager
    @EnvironmentObject var faceBit: FaceBitPeripheral
    
    var body: some View {
        VStack {
            Text("FaceBit Companion App")
                .font(.system(.largeTitle))
                .padding()
            Divider()
            Text("FaceBit Device State")
                .font(.system(.headline))
            Text(faceBit.state.rawValue)
            if faceBit.state == .connected {
                Divider()
                HStack {
                    Text("Temperature: \(faceBit.latestTemperature), \(faceBit.TemperatureReadings.count)")
                    Text("Pressure: \(faceBit.latestPressure), \(faceBit.PressureReadings.count)")
                }
                Divider()
                Text("Live Pressure Reading")
                LiveLinePlot()
                    .environmentObject(faceBit)
            }
        
        }.onAppear(perform: searchForFaceBit)
    }
    
    private func searchForFaceBit() {
        print("searching")
        bluetoothManager.searchFor(peripheral: faceBit)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BluetoothConnectionManager.shared)
            .environmentObject(FaceBitPeripheral())
    }
}
