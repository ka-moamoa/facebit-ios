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
                .onAppear(perform: {
                   setupDatabase()
                })
        }
    }
    
    func setupDatabase() {
        var event = Event(
            id: nil,
            eventType: .other,
            otherEventLabel: "none",
            startDate: Date(),
            endDate: Date()
        )

        var dataRead = TimeSeriesDataRead(
            id: nil,
            dataType: .pressure,
            frequency: 25.0,
            millisecondOffset: 0,
            startTime: Date(),
            numSamples: 100
        )

        var tsM = TimeSeriesMeasurement(
            id: nil,
            value: 10.0,
            date: Date(),
            dataReadId: nil, eventId: nil
        )
        
//        do {
//            try event.save()
//            try dataRead.save()
//
//            tsM.eventId = event.id
//            tsM.dataReadId = dataRead.id
//            try tsM.save()
//
//            let req = TimeSeriesMeasurement_New
//                .including(optional: TimeSeriesMeasurement_New.event)
//                .including(optional: TimeSeriesMeasurement_New.dataRead)
//                .asRequest(of: TimeSeriesMeasurementInfo.self)
//
//            let tsMs = try appDatabase.dbWriter.read { (db) in
//                try req.fetchAll(db)
//            }
//
//            print(tsMs)
//
//
//        } catch {
//            print()
//        }
        
//        if let db = SQLiteDatabase.main {
//            for table in SQLiteDatabase.tables {
//                db.createTable(table: table)
//            }
//        }
    }
}
