//
//  ActiveEventView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/1/21.
//

import SwiftUI
import GRDB

struct ActiveEventView: View {
    @Binding var activeEvent: Event?
    
    var body: some View {
        VStack(spacing: 16.0) {
            
            Text("Recording Event")
                .font(.largeTitle)
            
            if var event = activeEvent {
                
                Divider()
                EventSummaryView(event: event)
                Divider()
                
                PrimaryButton(
                    action: { insertEventTag(for: event) },
                    content: {
                        Text("Tag")
                    }
                )
                
                Divider()
                
                PrimaryButton(
                    action: { endEvent(event: &event) },
                    content: {
                        Text("End Event")
                    }
                )
            }
        }
    }
    
    private func insertEventTag(for event: Event) {
        var ts = Timestamp(
            id: nil,
            dataType: .eventTag,
            date: Date(),
            eventId: event.id
        )
        
        do {
            try ts.save()
        } catch {
            PersistanceLogger.error("unable to save timestamp: \(error.localizedDescription)")
        }
    }
    
    private func endEvent(event: inout Event) {
        do { try event.end() } catch {
            PersistanceLogger.error("Cannot update event \(error.localizedDescription)")
        }
        
        defer {
            activeEvent = nil
        }
        
        guard let endDate = event.endDate,
              let eventId = event.id else { return }
        
        do {
            try AppDatabase.shared.dbWriter.write { (db) in
                let arguments: StatementArguments =  [
                    "eventId": eventId,
                    "startDate": event.startDate,
                    "endDate": endDate
                ]

                // update data read records
                try db.execute(
                    sql: """
                         UPDATE \(TimeSeriesDataRead.databaseTableName)
                         SET event_id = :eventId
                         WHERE start_time >= :startDate;
                        """,
                    arguments: arguments
                )
                
                // update time series records
                try db.execute(
                    sql: """
                        UPDATE \(TimeSeriesMeasurement.databaseTableName)
                        SET event_id = :eventId
                        WHERE date >= :startDate
                            AND date <= :endDate;
                    """,
                    arguments: arguments
                )
                
                // update metric measurements
                try db.execute(
                    sql: """
                        UPDATE \(MetricMeasurement.databaseTableName)
                        SET event_id = :eventId
                        WHERE date >= :startDate
                            AND date <= :endDate;
                    """,
                    arguments: arguments
                )
            }
        } catch {
            PersistanceLogger.error("Cannot update time series records: \(error.localizedDescription)")
        }
    }
}

struct ActiveEventView_Previews: PreviewProvider {
    @State static var activeEvent: Event? = nil
    
    static var previews: some View {
        ActiveEventView(activeEvent: $activeEvent)
    }
}
