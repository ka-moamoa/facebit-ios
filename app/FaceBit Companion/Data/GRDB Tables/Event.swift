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
    var eventType: EventType
    var otherEventLabel: String?
    var notes: String?
    var startDate: Date
    var endDate: Date?
    
    enum EventType: String, CaseIterable, Codable, Identifiable, DatabaseValueConvertible {
        case normalBreathing = "normal_breathing"
        case deepBreathing = "deep_breathing"
        case talking = "talking"
        case cough = "cough"
        case maskOff = "mask_off"
        case other = "other"
        
        var id: String { self.rawValue }
    }

    
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
    
    static let measurementForeignKey = ForeignKey([TimeSeriesMeasurement.CodingKeys.eventId.rawValue])
    static let measurements = hasMany(TimeSeriesMeasurement.self, using: measurementForeignKey)
    var measurements: QueryInterfaceRequest<TimeSeriesMeasurement> {
        request(for: Event.measurements)
    }
    
    static let metricForeignKey = ForeignKey([MetricMeasurement.CodingKeys.eventId.rawValue])
    static var metrics = hasMany(MetricMeasurement.self, using: metricForeignKey)
    var metrics: QueryInterfaceRequest<MetricMeasurement> {
        request(for: Event.metrics)
    }
}

extension Event: FetchableRecord, MutablePersistableRecord {
    enum Columns {
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

extension Event {
    static func activeEvent(appDatabase: AppDatabase=AppDatabase.shared) throws -> Event? {
        return try appDatabase.dbWriter.read({ (db) in
            try Event
                .filter(Event.Columns.endDate == nil)
                .order(Event.Columns.startDate.desc)
                .fetchOne(db)
        })
    }
    
    mutating func end(appDatabase: AppDatabase=AppDatabase.shared, endDate: Date=Date()) throws {
        self.endDate = endDate
        try self.save()
    }
}
