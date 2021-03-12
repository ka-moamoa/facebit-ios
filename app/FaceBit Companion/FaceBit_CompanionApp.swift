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
    
    let maskVM: MaskViewModel = MaskViewModel()
    
    let appDatabase = AppDatabase.shared
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(facebit)
                .environmentObject(maskVM)
                .onAppear(perform: {
                   setupDatabase()
                })
                
        }
    }
    
    func setupDatabase() {
        var event = Event(id: nil, eventType: "none", otherEventLabel: "none", startDate: Date(), endDate: Date())
        do {
            try appDatabase.insert(&event)
        } catch {
            print()
        }
        
        if let db = SQLiteDatabase.main {
            for table in SQLiteDatabase.tables {
                db.createTable(table: table)
            }
        }
    }
}
