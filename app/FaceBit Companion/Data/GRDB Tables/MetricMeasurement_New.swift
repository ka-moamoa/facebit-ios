//
//  MetricMeasurement_New.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
//

import Foundation
import GRDB

struct MetricMeasurement_New: Identifiable, Equatable, Codable {
    enum DataType: String, CaseIterable, Identifiable, Codable {
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

extension MetricMeasurement_New: TableRecord {
    static var databaseTableName: String = "metric_measurement"
    
    static let event = belongsTo(Event.self)
    var event: QueryInterfaceRequest<Event> {
        request(for: MetricMeasurement_New.event)
    }
}


extension MetricMeasurement_New: FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
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

extension MetricMeasurement_New: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.value.rawValue, .double).notNull()
            t.column(CodingKeys.timestamp.rawValue, .integer).notNull()
            t.column(CodingKeys.date.rawValue, .datetime).notNull()
        })
    }
}
