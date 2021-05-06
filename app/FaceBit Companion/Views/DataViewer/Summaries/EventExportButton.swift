//
//  EventExportButton.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import SwiftUI
import GRDB

struct EventExportButton: View {
    var event: Event
    
    var body: some View {
        Button(
            action: {
                try? AppDatabase.shared.dbWriter.read { (db) in
                    let eventDetail = try? Event
                        .filter(Column("id") == event.id!)
                        .including(all: Event.measurements)
                        .including(all: Event.timeSeriesDataReads)
                        .including(all: Event.metrics)
                        .including(all: Event.timestamps)
                        .asRequest(of: EventDetailed.self)
                        .fetchOne(db)

                    if let path = ShareUtil.saveJSON(from: eventDetail, fileName: "event_\(event.id!)") {
                        ShareUtil.share(path: path)
                    }
                }
            }, label: {
                Text("Export Event: \(event.id!)")
            }
        )
    }
}

struct EventExportButton_Previews: PreviewProvider {
    static var previews: some View {
        EventExportButton(
            event: Event(
                id: 0,
                eventName: "test event",
                eventType: .stationary,
                maskType: .other,
                otherEventLabel: nil,
                notes: nil,
                startDate: Date(),
                endDate: nil
            )
        )
    }
}
