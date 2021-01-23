//
//  FaceBit_CompanionApp.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import SwiftUI

@main
struct FaceBit_CompanionApp: App {
    let facebit = FaceBitPeripheral()
    
    
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
            do {
                for table in SQLiteDatabase.tables {
                    try db.createTable(table: table)
                }
            } catch {
                PersistanceLogger.error("unable to setup database: \(db.errorMessage)")
            }
        }
    }
}
