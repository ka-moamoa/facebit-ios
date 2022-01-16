//
//  Timestamp_New.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
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
    var name: String?
    let dataType: DataType
    let date: Date
    var eventId: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
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
        static let name = Column(CodingKeys.name)
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
            t.column(CodingKeys.name.rawValue, .text)
            t.column(CodingKeys.dataType.rawValue, .text).notNull()
            t.column(CodingKeys.date.rawValue, .datetime).notNull()
            
            t.column(CodingKeys.eventId.rawValue, .integer)
                .indexed()
                .references(Event.databaseTableName, onDelete: .setNull)
        })
    }
}
