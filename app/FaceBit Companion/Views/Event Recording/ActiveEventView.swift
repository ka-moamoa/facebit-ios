//
//  ActiveEventView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/1/21.
//

import SwiftUI

struct ActiveEventView: View {
    @Binding var activeEvent: SmartPPEEvent?
    
    var body: some View {
        VStack(spacing: 16.0) {
            Text("Recording Event")
                .font(.largeTitle)
            if let event = activeEvent {
                Text("Start Date: \(event.startDate!)")
                    .font(.body)
                Button(action: { endEvent(event: event) }, label: {
                    Text("End Event")
                })
            }
        }
    }
    
    private func endEvent(event: SmartPPEEvent) {
        guard let startDate = event.startDate else { return }
        
        event.end()
        
        defer {
            activeEvent = nil
        }
        
        guard let endDate = event.endDate else { return }
        
        let updateQuery = """
            UPDATE \(TimeSeriesMeasurement.tableName)
            SET event_id = \(event.id)
            WHERE date >= '\(SQLiteDatabase.dateFormatter.string(from: startDate))'
            AND date <= '\(SQLiteDatabase.dateFormatter.string(from: endDate))';
        """
        
        try? SQLiteDatabase.main?.executeSQL(sql: updateQuery)
    }
}

struct ActiveEventView_Previews: PreviewProvider {
    @State static var activeEvent: SmartPPEEvent? = nil
    
    static var previews: some View {
        ActiveEventView(activeEvent: $activeEvent)
    }
}
