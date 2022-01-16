//
//  NewEventFormView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/29/21.
//
//  @copyright Copyright (c) 2022 Ka Moamoa
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the license.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI

struct StartEventView: View {
    @Binding var activeEvent: Event?
    
    @State private var selectedEventType: Event.EventType = .stationary
    @State private var selectedMaskType: Mask.MaskType = .cloth
    @State private var eventName: String = ""
    @State private var otherEventName: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        Form {
            
            TextField("Event Name", text: $eventName)
            
            Picker(selection: $selectedEventType, label: Text("Event Type"), content: {
                ForEach(Event.EventType.allCases) { t in
                    Text(t.readableString).tag(t)
                }
            })
            
            if selectedEventType == .other {
                TextField("Other Event Name: ", text: $otherEventName)
            }
            
            Picker(selection: $selectedMaskType, label: Text("Mask Type"), content: {
                ForEach(Mask.MaskType.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            })
            
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
            eventName: eventName,
            eventType: selectedEventType,
            maskType: selectedMaskType,
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
