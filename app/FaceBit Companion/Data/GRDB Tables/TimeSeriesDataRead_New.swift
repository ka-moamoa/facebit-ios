//
//  TimeSeriesDataRead.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
//

import Foundation
import GRDB

struct TimeSeriesDataRead_New: Identifiable, Equatable, Codable {
    var id: Int64?
    let dataType: DataType
    let frequency: Double
    let millisecondOffset: Int
    let startTime: Date
    let numSamples: Int
    
    enum DataType: String, Identifiable, Equatable, Codable, DatabaseValueConvertible {
        case none = "none"
        case pressure = "pressure"
        case temperature = "temperature"

        var id: String { return rawValue }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dataType = "data_type"
        case frequency = "frequency"
        case millisecondOffset = "millisecond_offset"
        case startTime = "start_time"
        case numSamples = "num_samples"
    }
}

extension TimeSeriesDataRead_New: TableRecord {
    static var databaseTableName: String = "time_series_data_read"
    
    static var measurementForeignKey = ForeignKey([TimeSeriesMeasurement_New.CodingKeys.dataReadId.rawValue])
    static var measurements = hasMany(TimeSeriesMeasurement_New.self, using: measurementForeignKey)
    var measurements: QueryInterfaceRequest<TimeSeriesMeasurement_New> {
        request(for: TimeSeriesDataRead_New.measurements)
    }
}

extension TimeSeriesDataRead_New: FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let dataType = Column(CodingKeys.dataType)
        static let frequency = Column(CodingKeys.frequency)
        static let millisecondOffset = Column(CodingKeys.millisecondOffset)
        static let startTime = Column(CodingKeys.startTime)
        static let numSamples = Column(CodingKeys.numSamples)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        self.id = rowID
    }
}

extension TimeSeriesDataRead_New: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: "time_series_data_read", body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.dataType.rawValue, .text).notNull()
            t.column(CodingKeys.frequency.rawValue, .integer).notNull()
            t.column(CodingKeys.millisecondOffset.rawValue, .double).notNull()
            t.column(CodingKeys.numSamples.rawValue, .integer).notNull()
            t.column(CodingKeys.startTime.rawValue, .datetime).notNull()
        })
    }
}
