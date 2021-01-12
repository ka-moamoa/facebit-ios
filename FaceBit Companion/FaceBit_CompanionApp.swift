//
//  FaceBit_CompanionApp.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import SwiftUI

@main
struct FaceBit_CompanionApp: App {
    @StateObject private var bluetoothManager = BluetoothConnectionManager()
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothManager)
        }
    }
}
