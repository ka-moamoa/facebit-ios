//
//  NewEventFormView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/29/21.
//

import SwiftUI

struct StartEventView: View {
    @Binding var activeEvent: Event?
    
    @State private var selectedEventType: Event.EventType = .cough
    @State private var otherEventName: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        Form {
            Picker(selection: $selectedEventType, label: Text("Event Type"), content: {
                ForEach(Event.EventType.allCases) { t in
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
        
        var event = Event(
            id: nil,
            eventType: selectedEventType,
            otherEventLabel: selectedEventType == .other ? otherEventName : "",
            notes: notes,
            startDate: Date(),
            endDate: nil
        )
        
        do {
            try event.save()
            self.activeEvent = event
        } catch {
            PersistanceLogger.error("Cannot create event: \(error.localizedDescription)")
        }
    }
}

struct StartEventView_Previews: PreviewProvider {
    @State static var activeEvent: Event? = nil
    
    static var previews: some View {
        StartEventView(activeEvent: $activeEvent)
    }
}
