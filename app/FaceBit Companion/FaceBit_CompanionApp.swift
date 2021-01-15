//
//  FaceBit_CompanionApp.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import SwiftUI

@main
struct FaceBit_CompanionApp: App {
    @StateObject private var bluetoothManager = BluetoothConnectionManager.shared
    @StateObject private var facebit = FaceBitPeripheral()
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothManager)
                .environmentObject(facebit)
                
        }
    }
}
