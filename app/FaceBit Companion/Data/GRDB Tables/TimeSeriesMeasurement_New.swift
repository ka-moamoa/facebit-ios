//
//  TimeSeriesMeasurement.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
//

import Foundation
import GRDB

struct TimeSeriesMeasurementInfo: FetchableRecord, Decodable {
    var timeseriesMeasurement: TimeSeriesMeasurement_New
    var dataRead: TimeSeriesDataRead_New
    var event: Event?
    
    enum CodingKeys: String, CodingKey {
        case timeseriesMeasurement = "time_series_measurement"
        case dataRead = "time_series_data_read"
        case event = "event"
    }
}

struct TimeSeriesMeasurement_New: Identifiable, Equatable, Codable {
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

extension TimeSeriesMeasurement_New: TableRecord {
    static var databaseTableName: String = "time_series_measurement"
    
    static let dataRead = belongsTo(TimeSeriesDataRead_New.self)
    var dataRead: QueryInterfaceRequest<TimeSeriesDataRead_New> {
        request(for: TimeSeriesMeasurement_New.dataRead)
    }
    
    static let event = belongsTo(Event.self)
    var event: QueryInterfaceRequest<Event> {
        request(for: TimeSeriesMeasurement_New.event)
    }
}

extension TimeSeriesMeasurement_New: FetchableRecord, MutablePersistableRecord {
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

extension TimeSeriesMeasurement_New: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.value.rawValue, .double).notNull()
            t.column(CodingKeys.date.rawValue, .datetime).notNull()
            
            t.column(CodingKeys.dataReadId.rawValue, .integer)
                .indexed()
                .notNull()
                .references(TimeSeriesDataRead_New.databaseTableName)
            
            t.column(CodingKeys.eventId.rawValue, .integer)
                .indexed()
                .references(Event.databaseTableName)
        })
    }
}
