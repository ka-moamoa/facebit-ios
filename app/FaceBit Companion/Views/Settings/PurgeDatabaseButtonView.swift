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
            for table in SQLiteDatabase.tables {
                db.createTable(table: table)
            }
        }
    }
}

struct PurgeDatabaseButtonView___Previews: PreviewProvider {
    static var previews: some View {
        PurgeDatabaseButtonView()
    }
}
