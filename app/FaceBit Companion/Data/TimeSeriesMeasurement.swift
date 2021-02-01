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
    var event: SmartPPEEvent?
    
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
            event_id INT,

            FOREIGN KEY (event_id)
                REFERENCES \(SmartPPEEvent.tableName) (id)
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
        
        if event != nil {
            return """
                INSERT INTO \(TimeSeriesMeasurement.tableName)
                (value, date, type, event_id)
                VALUES (\(value), '\(SQLiteDatabase.dateFormatter.string(from: date))', '\(type.rawValue)', \(event!.id) );
            """
        } else {
            return """
                INSERT INTO \(TimeSeriesMeasurement.tableName)
                (value, date, type)
                VALUES (\(value), '\(SQLiteDatabase.dateFormatter.string(from: date))', '\(type.rawValue)');
            """
        }
    }
    
    func didInsert(id: Int) {
        self.id = id
        self.isInserted = true
    }
}

extension Array where Element == TimeSeriesMeasurement {
    func insertSQL() -> String {
        var sql = """
            INSERT INTO \(TimeSeriesMeasurement.tableName)
            (value, date, type, event_id)
            VALUES
        """
        
        for ts in self {
            if ts.event == nil {
                sql += " (\(ts.value), '\(SQLiteDatabase.dateFormatter.string(from: ts.date))', '\(ts.type.rawValue)', NULL),"
            } else {
                sql += " (\(ts.value), '\(SQLiteDatabase.dateFormatter.string(from: ts.date))', '\(ts.type.rawValue)', \(ts.event!.id)),"
            }
        }
        
        sql = String(sql.dropLast())
        sql += ";"
        
        return sql
    }
}
