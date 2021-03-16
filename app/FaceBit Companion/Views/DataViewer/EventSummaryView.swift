//
//  EventSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI

struct EventSummaryView: View {
    var event: Event
    
    var body: some View {
        Text("\(event.eventType.rawValue)")
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
