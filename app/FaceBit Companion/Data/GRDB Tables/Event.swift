//
//  Event.swift
//  FaceBit Companion
//
//  Created by blaine on 3/11/21.
//

import Foundation
import GRDB

struct Event: Identifiable, Equatable, Codable {
    var id: Int64?
    var eventType: String
    var otherEventLabel: String?
    var notes: String?
    var startDate: Date
    var endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case eventType = "event_type"
        case otherEventLabel = "other_event_label"
        case notes = "notes"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

extension Event: TableRecord {
    static var databaseTableName: String = "event"
}

extension Event: FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let eventType = Column(CodingKeys.eventType)
        static let otherEventType = Column(CodingKeys.otherEventLabel)
        static let notes = Column(CodingKeys.notes)
        static let startDate = Column(CodingKeys.startDate)
        static let endDate = Column(CodingKeys.endDate)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        self.id = rowID
    }
}

extension Event: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.eventType.rawValue, .text).notNull()
            t.column(CodingKeys.otherEventLabel.rawValue, .text)
            t.column(CodingKeys.notes.rawValue, .text)
            t.column(CodingKeys.startDate.rawValue, .datetime)
            t.column(CodingKeys.endDate.rawValue, .datetime)
        })
    }
}
