//
//  NewEventFormView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/29/21.
//

import SwiftUI

struct StartEventView: View {
    @Binding var activeEvent: SmartPPEEvent?
    
    @State private var selectedEventType: SmartPPEEventType = .cough
    @State private var otherEventName: String = ""
    @State private var notes: String = ""
    
    var body: some View {
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
        Button(action: createEvent, label: {
            Text("Start Event")
        })
        .padding(.all)
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
        activeEvent = event
    }
}

struct StartEventView_Previews: PreviewProvider {
    @State static var activeEvent: SmartPPEEvent? = nil
    
    static var previews: some View {
        StartEventView(activeEvent: $activeEvent)
    }
}
