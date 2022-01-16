//
//  TimeSeriesMeasurement.swift
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

struct TimeSeriesMeasurement: Identifiable, Equatable, Codable {
    var id: Int64?
    var value: Double
    var date: Date
    var dataReadId: Int64?
    var eventId: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case value = "value"
        case date = "date"
        case dataReadId = "data_read_id"
        case eventId = "event_id"
    }
}

extension TimeSeriesMeasurement: TableRecord {
    static var databaseTableName: String = "time_series_measurement"
    
    static let dataRead = belongsTo(TimeSeriesDataRead.self)
    var dataRead: QueryInterfaceRequest<TimeSeriesDataRead> {
        request(for: TimeSeriesMeasurement.dataRead)
    }
    
    static let event = belongsTo(Event.self)
    var event: QueryInterfaceRequest<Event> {
        request(for: TimeSeriesMeasurement.event)
    }
}

extension TimeSeriesMeasurement: FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let value = Column(CodingKeys.value)
        static let date = Column(CodingKeys.date)
        static let dataReadId = Column(CodingKeys.dataReadId)
        static let eventId = Column(CodingKeys.eventId)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        self.id = rowID
    }
}

extension TimeSeriesMeasurement: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.value.rawValue, .double).notNull()
            t.column(CodingKeys.date.rawValue, .datetime).notNull()
            
            t.column(CodingKeys.dataReadId.rawValue, .integer)
                .indexed()
                .notNull()
                .references(TimeSeriesDataRead.databaseTableName, onDelete: .cascade)
            
            t.column(CodingKeys.eventId.rawValue, .integer)
                .indexed()
                .references(Event.databaseTableName, onDelete: .setNull)
        })
    }
}
