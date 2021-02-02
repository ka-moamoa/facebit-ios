//
//  NewEventFormView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/29/21.
//

import SwiftUI

struct EventFormView: View {
    @State private var currentEvent: SmartPPEEvent?
    @State private var selectedEventType: SmartPPEEventType = .cough
    @State private var otherEventName: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        if currentEvent == nil
        {
            Form {
                Picker(selection: $selectedEventType, label: Text("Event Type"), content: {
                    ForEach(SmartPPEEventType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                })
                if selectedEventType == .other {
                    TextField("Other Event Name: ", text: $otherEventName)
                }
                TextField("Event Notes", text: $notes)
            }
            Spacer()
            Button(action: createEvent, label: {
                Text("Start Event")
            })
            .padding(16.0)
        } else {
            Text("Recording Event: \(currentEvent!.eventType.rawValue)")
            Button(action: endEvent, label: {
                Text("End Event")
            })
            .padding(16.0)
        }
    }
    
    private func createEvent() {
        let event = SmartPPEEvent(
            eventType: selectedEventType,
            otherEventLabel: selectedEventType == .other ? otherEventName : "",
            notes: notes,
            startDate: Date()
        )
        try? SQLiteDatabase.main?.insertRecord(record: event)
        event.start()
        currentEvent = event
    }
    
    private func endEvent() {
        defer {
            self.currentEvent = nil
            notes = ""
            otherEventName = ""
        }
        
        guard let currentEvent = currentEvent,
              let startDate = currentEvent.startDate else { return }
        
        currentEvent.end()
        
        guard let endDate = currentEvent.endDate else { return }
        
        let updateQuery = """
            UPDATE \(TimeSeriesMeasurement.tableName)
            SET event_id = \(currentEvent.id)
            WHERE date >= '\(SQLiteDatabase.dateFormatter.string(from: startDate))'
            AND date <= '\(SQLiteDatabase.dateFormatter.string(from: endDate))';
        """
        
        try? SQLiteDatabase.main?.executeSQL(sql: updateQuery)
    }
}

struct NewEventFormView_Previews: PreviewProvider {
    static var previews: some View {
        EventFormView()
    }
}
