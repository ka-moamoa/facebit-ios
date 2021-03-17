//
//  EventSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI
import GRDB

struct EventSummaryView: View {
    var event: Event
    @State private var selection: String? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            DataSummaryFieldView(
                title: "Id",
                value: "\(event.id ?? -1)"
            )
            
            DataSummaryFieldView(
                title: "Event Type",
                value: event.eventType != .other ? "\(event.eventType.rawValue)" : "\(event.otherEventLabel ?? "--")"
            )
            
            DataSummaryFieldView(
                title: "Start Date",
                value: "\(event.startDate)"
            )
            
            DataSummaryFieldView(
                title: "End Date",
                value: event.endDate == nil ? "--" : "\(event.endDate!)"
            )
            
            
            if let notes = event.notes, notes != "" {
                Text("Notes: ")
                    .bold()
                Text("\(notes)")
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 16)
                    .font(.body)
            }
        }
        .padding(.all, 8)
    }
}

struct EventSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        EventSummaryView(
            event: Event(
                id: nil,
                eventType: .cough,
                otherEventLabel: nil,
                notes: nil,
                startDate: Date(),
                endDate: nil
            )
        )
    }
}
