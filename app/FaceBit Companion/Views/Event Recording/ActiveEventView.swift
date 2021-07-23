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
    
    @State private var tagName: String = ""
    @State private var showingAllTags: Bool = false
    
    var body: some View {
        VStack(spacing: 16.0) {
            
            Text("Recording Event")
                .font(.largeTitle)
            
            if var event = activeEvent {
                
                Divider()
                EventSummaryView(event: event)
                Divider()
                
                HStack(spacing: 16.0) {
                    TextField("Tag Name", text: $tagName)
                    PrimaryButton(
                        action: { insertEventTag(for: event) },
                        content: {
                            Text("Add New Tag")
                        }
                    )
                }
                
                NavigationLink(
                    destination: DataListView(
                        viewModel: DatabaseTableViewModel(
                            appDatabase: AppDatabase.shared,
                            request: Timestamp
                                .filter(Timestamp.Columns.dataType == Timestamp.DataType.eventTag.rawValue)
                                .filter(Timestamp.Columns.eventId == event.id)
                                .order(Timestamp.Columns.date.desc)
                        ),
                        rowBuilder: { ts in TimestampSummaryView(timestamp: ts) },
                        title: "Timestamps"
                    )
                ) {
                    Text("View All Tags")
                        .foregroundColor(Color("PrimaryWhite"))
                        .padding(16.0)
                }
                .navigationBarTitle("Navigation")
                .frame(height: 50.0)
                .background(
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color("PrimaryBrown"))
                )
                
//                PrimaryButton(
//                    action: { showingAllTags.toggle() },
//                    content: {
//                        Text("View All Tags")
//                    }
//                ).sheet(isPresented: $showingAllTags, content: {
//
//                })
                
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
            name: $tagName.wrappedValue,
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
