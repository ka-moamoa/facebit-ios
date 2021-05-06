//
//  Timestamp_New.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
//

import Foundation
import GRDB

struct Timestamp: Identifiable, Equatable, Codable {
    enum DataType: String, CaseIterable, Identifiable, Codable, DatabaseValueConvertible {
        case peripheralSync = "peripheral_sync"
        case maskOn = "mask_on"
        case maskOff = "mask_off"
        case eventTag = "event_tag"
        
        var id: String { return self.rawValue }
    }
    
    var id: Int64?
    let dataType: DataType
    let date: Date
    var eventId: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dataType = "data_type"
        case date = "date"
        case eventId = "event_id"
    }
}

extension Timestamp: TableRecord {
    static var databaseTableName: String = "timestamp"
    
    static let event = belongsTo(Event.self)
    var event: QueryInterfaceRequest<Event> {
        request(for: Timestamp.event)
    }
}

extension Timestamp: FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let dataType = Column(CodingKeys.dataType)
        static let date = Column(CodingKeys.date)
        static let eventId = Column(CodingKeys.eventId)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        self.id = rowID
    }
}

extension Timestamp: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.dataType.rawValue, .text).notNull()
            t.column(CodingKeys.date.rawValue, .datetime).notNull()
            
            t.column(CodingKeys.eventId.rawValue, .integer)
                .indexed()
                .references(Event.databaseTableName, onDelete: .setNull)
        })
    }
}
