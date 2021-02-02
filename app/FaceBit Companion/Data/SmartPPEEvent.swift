//
//  SmartPPEEvent.swift
//  FaceBit Companion
//
//  Created by blaine on 1/19/21.
//

import Foundation
import SQLite3

enum SmartPPEEventType: String, CaseIterable, Codable, Identifiable {
    case normalBreathing = "normal_breathing"
    case deepBreathing = "deep_breathing"
    case talking = "talking"
    case cough = "cough"
    case other = "other"
    
    var id: String { self.rawValue }
}

class SmartPPEEvent: Codable, SQLiteTable {
    static var memId: MemoryId = MemoryId()
    static var createSQL: String = """
        CREATE TABLE IF NOT EXISTS \(SmartPPEEvent.tableName)(
            id INTEGER PRIMARY KEY NOT NULL,
            event_type TEXT NOT NULL,
            other_event_label TEXT,
            notes TEXT,
            start_date TEXT,
            end_date TEXT
        );
    """
    
    static var tableName: String = "event"
    
    var id: Int
    let eventType: SmartPPEEventType
    let otherEventLabel: String?
    let notes: String?
    var startDate: Date?
    var endDate: Date?
    
    var isInserted: Bool = false
    
    init(
        id: Int = SmartPPEEvent.memId.next,
        eventType: SmartPPEEventType,
        otherEventLabel: String?=nil,
        notes: String?=nil,
        startDate: Date?=nil,
        endDate: Date?=nil,
        isInserted: Bool = false
    ) {
        self.id = id
        self.eventType = eventType
        self.otherEventLabel = otherEventLabel
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.isInserted = isInserted
    }
    
    func start() {
        startDate = Date()
        
        guard isInserted else { return }
        
        let startDateString = SQLiteDatabase.dateFormatter.string(from: startDate!)
        let updateSQL = """
            UPDATE \(SmartPPEEvent.tableName)
            SET start_date = '\(startDateString)'
            WHERE id = \(id);
        """
        update(sql: updateSQL)
    }
    
    func end() {
        endDate = Date()
        
        guard isInserted else { return }
        
        let endDateString = SQLiteDatabase.dateFormatter.string(from: endDate!)
        let updateSQL = """
            UPDATE \(SmartPPEEvent.tableName)
            SET end_date = '\(endDateString)'
            WHERE id = \(id);
        """
        update(sql: updateSQL)
        
    }
    
    func insertSQL() -> String {
        let startTimeString = startDate != nil ? SQLiteDatabase.dateFormatter.string(from: startDate!) : ""
        let endTimeString = endDate != nil ? SQLiteDatabase.dateFormatter.string(from: endDate!) : ""
        
        return """
            INSERT INTO \(SmartPPEEvent.tableName)
            (event_type, other_event_label, notes, start_date, end_date)
            VALUES ('\(eventType.rawValue)', '\(otherEventLabel ?? "")', '\(notes ?? "")', '\(startTimeString)', '\(endTimeString)');
        """
    }
    
    func didInsert(id: Int) {
        self.id = id
        self.isInserted = true
    }
    
    static func getActiveEvent(callback: @escaping (SmartPPEEvent?)->Void) {
        SQLiteDatabase.queue.async {
            guard let db = SQLiteDatabase.main else {
                DispatchQueue.main.async { callback(nil) }
                return
            }
            let sql = """
                SELECT id, event_type, other_event_label, notes, start_date, end_date
                FROM event
                WHERE end_date IS NULL or end_date = ''
                ORDER BY start_date DESC
                LIMIT 1
            """
            guard let statement = try? db.prepareStatement(sql: sql) else {
                DispatchQueue.main.async { callback(nil) }
                return
            }

            defer {
                sqlite3_finalize(statement)
            }

            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))

                guard let eventType = SmartPPEEventType(rawValue: String(cString: sqlite3_column_text(statement, 1))),
                      let startDate = SQLiteDatabase.dateFormatter.date(from: String(cString: sqlite3_column_text(statement, 4))) else {

                    DispatchQueue.main.async { callback(nil) }
                    return
                }

                let otherEventLabel = String(cString: sqlite3_column_text(statement, 2))
                let notes = String(cString: sqlite3_column_text(statement, 3))

                let endDate = SQLiteDatabase.dateFormatter.date(from: String(cString: sqlite3_column_text(statement, 5)))

                let event = SmartPPEEvent(
                    id: id,
                    eventType: eventType,
                    otherEventLabel: otherEventLabel,
                    notes: notes,
                    startDate: startDate,
                    endDate: endDate,
                    isInserted: true
                )

                DispatchQueue.main.async { callback(event) }
            } else {
                DispatchQueue.main.async { callback(nil) }
            }
        }
    }
    
    private func update(sql: String) {
        do {
            try SQLiteDatabase.main?.updateRecord(record: self, updateSQL: sql)
        } catch {
            PersistanceLogger.error("unable to update SmartPPEEvent record")
        }
    }
}
