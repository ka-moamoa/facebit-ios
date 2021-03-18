//
//  FaceBit_CompanionApp.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import SwiftUI
import GRDB

@main
struct FaceBit_CompanionApp: App {
    let facebit = FaceBitPeripheral(readChars: [
        TemperatureCharacteristic(),
        PressureCharacteristic(),
        RespiratoryRateCharacteristic(),
        HeartRateCharacteristic(),
        MaskOnOffCharacteristic()
    ])
        
    let appDatabase = AppDatabase.shared
    let maskVM: MaskViewModel = MaskViewModel(db: AppDatabase.shared)
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(facebit)
                .environmentObject(maskVM)
        }
    }
}
