//
//  FaceBit_CompanionApp.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import SwiftUI

@main
struct FaceBit_CompanionApp: App {
    let facebit = FaceBitPeripheral(readChars: [
        TemperatureCharacteristic(),
        PressureCharacteristic(),
        RespiratoryRateCharacteristic(),
        HeartRateCharacteristic()
    ])
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(facebit)
                .onAppear(perform: {
                   setupDatabase()
                })
                
        }
    }
    
    func setupDatabase() {
        if let db = SQLiteDatabase.main {
            for table in SQLiteDatabase.tables {
                db.createTable(table: table)
            }
        }
    }
}
