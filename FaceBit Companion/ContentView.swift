//
//  ContentView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bluetoothManager: BluetoothConnectionManager
    
    var body: some View {
        VStack {
            Text("FaceBit Companion App")
                .font(.system(.largeTitle))
                .padding()
            Divider()
            Text("Central Connection State")
                .font(.system(.headline))
            Text(bluetoothManager.stateString)
                .font(.system(.subheadline))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BluetoothConnectionManager())
    }
}
