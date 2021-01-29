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
        try? SQLiteDatabase.main?.executeSQL(
            sql: "DELETE FROM \(TimeSeriesMeasurement.tableName);"
        )
        try? SQLiteDatabase.main?.executeSQL(
            sql: "DELETE FROM \(SmartPPEEvent.tableName);"
        )
    }
}

struct PurgeDatabaseButtonView___Previews: PreviewProvider {
    static var previews: some View {
        PurgeDatabaseButtonView()
    }
}
