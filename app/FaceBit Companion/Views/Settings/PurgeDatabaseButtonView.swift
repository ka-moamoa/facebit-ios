//
//  PurgeDatabaseButtonView().swift
//  FaceBit Companion
//
//  Created by blaine on 1/29/21.
//

import SwiftUI

struct PurgeDatabaseButtonView: View {
    var body: some View {
        Button(action: {
            purge()
        }, label: {
            Text("Purge Database")
                .padding()
        })
    }
    
    private func purge() {
                
        SQLiteDatabase.openDatabase(purge: true)
        
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

struct PurgeDatabaseButtonView___Previews: PreviewProvider {
    static var previews: some View {
        PurgeDatabaseButtonView()
    }
}
