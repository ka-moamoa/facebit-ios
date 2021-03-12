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
        var event = Event(
            id: nil,
            eventType: "none",
            otherEventLabel: "none",
            startDate: Date(),
            endDate: Date()
        )
        
        var dataRead = TimeSeriesDataRead_New(
            id: nil,
            dataType: .pressure,
            frequency: 25.0,
            millisecondOffset: 0,
            startTime: Date(),
            numSamples: 100
        )
        
        var tsM = TimeSeriesMeasurement_New(
            id: nil,
            value: 10.0,
            date: Date(),
            dataReadId: nil, eventId: nil
        )
        
        do {
            try event.save()
            try dataRead.save()
            
            tsM.eventId = event.id
            tsM.dataReadId = dataRead.id
            try tsM.save()
            
            let request = TimeSeriesMeasurement_New
                .including(optional: TimeSeriesMeasurement_New.dataRead)
                .including(optional: TimeSeriesMeasurement_New.event)
            
            try appDatabase.dbWriter.read { (db) in
                var tsMs = try event.measurements.fetchAll(db)
                print(tsMs)
            }
            
            
            
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
