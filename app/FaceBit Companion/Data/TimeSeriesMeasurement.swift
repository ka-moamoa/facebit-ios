//
//  Measurement.swift
//  FaceBit Companion
//
//  Created by blaine on 1/15/21.
//

import Foundation

class TimeSeriesMeasurement: Codable, SQLiteTable {
    enum DataType: String, Codable {
        case none = "none"
        case pressure = "pressure"
        case temperature = "temperature"
    }
    
    var id: Int
    let value: Double
    let date: Date
    let type: DataType
    let event: SmartPPEEvent?
    
    static func sampleSeries() -> [TimeSeriesMeasurement] {
        let startValue = 1.0
        let startDate = Date()
        
        
        var series: [TimeSeriesMeasurement] = []
        (0..<100).forEach { (i) in
            series.append(
                TimeSeriesMeasurement(
                    value: startValue*Double(i*2),
                    date: startDate + Double(i),
                    type: .pressure)
            )
        }
        
        
        return series
    }
    
    static var tableName = "time_series_measurement"
    static var createSQL = """
        CREATE TABLE IF NOT EXISTS \(TimeSeriesMeasurement.tableName)(
            id INTEGER PRIMARY KEY NOT NULL,
            value REAL NOT NULL,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            event TEXT
        );
    """
    
    static let memId = MemoryId()
    var isInserted: Bool
    
    init(
        id: Int=TimeSeriesMeasurement.memId.next,
        value: Double,
        date: Date,
        type: DataType,
        event: SmartPPEEvent?=nil,
        isInserted:Bool=false
    ) {
        self.id = id
        self.value = value
        self.date = date
        self.type = type
        self.event = event
        self.isInserted = isInserted
    }
    
    func insertSQL() -> String {
        return """
            INSERT INTO \(TimeSeriesMeasurement.tableName)
            (value, date, type, event)
            VALUES (\(value), '\(SQLiteDatabase.dateFormatter.string(from: date))', '\(type.rawValue)', '\(event?.rawValue ?? "")' );
        """
    }
    
    func didInsert(id: Int) {
        self.id = id
        self.isInserted = true
    }
}
