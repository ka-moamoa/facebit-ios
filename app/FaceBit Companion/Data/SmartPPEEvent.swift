//
//  SmartPPEEvent.swift
//  FaceBit Companion
//
//  Created by blaine on 1/19/21.
//

import Foundation

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
        endDate: Date?=nil
    ) {
        self.id = id
        self.eventType = eventType
        self.otherEventLabel = otherEventLabel
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
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
    
    private func update(sql: String) {
        do {
            try SQLiteDatabase.main?.updateRecord(record: self, updateSQL: sql)
        } catch {
            PersistanceLogger.error("unable to update SmartPPEEvent record")
        }
    }
}
