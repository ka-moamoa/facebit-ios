//
//  MetricMeasurement_New.swift
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

struct MetricMeasurement: Identifiable, Equatable, Codable {
    enum DataType: String, CaseIterable, Identifiable, Codable, DatabaseValueConvertible {
        case respiratoryRate = "respiratory_rate"
        case heartRate = "heart_rate"
        
        var id: String { return self.rawValue }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case value = "value"
        case dataType = "data_type"
        case timestamp = "timestamp"
        case date = "date"
        case eventId = "event_id"
    }
    
    var id: Int64?
    let value: Double
    let dataType: DataType
    let timestamp: Int64
    let date: Date
    let eventId: Int64?
}

extension MetricMeasurement: TableRecord {
    static var databaseTableName: String = "metric_measurement"
    
    static let event = belongsTo(Event.self)
    var event: QueryInterfaceRequest<Event> {
        request(for: MetricMeasurement.event)
    }
}


extension MetricMeasurement: FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let value = Column(CodingKeys.value)
        static let dataType = Column(CodingKeys.dataType)
        static let timestamp = Column(CodingKeys.timestamp)
        static let date = Column(CodingKeys.date)
        static let eventId = Column(CodingKeys.eventId)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        self.id = rowID
    }
}

extension MetricMeasurement: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.value.rawValue, .double).notNull()
            t.column(CodingKeys.dataType.rawValue, .text).notNull()
            t.column(CodingKeys.timestamp.rawValue, .integer).notNull()
            t.column(CodingKeys.date.rawValue, .datetime).notNull()
            t.column(CodingKeys.eventId.rawValue, .integer)
                .indexed()
                .references(Event.databaseTableName)
        })
    }
}
