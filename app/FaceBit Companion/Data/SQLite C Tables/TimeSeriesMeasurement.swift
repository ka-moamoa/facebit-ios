//
//  Measurement.swift
//  FaceBit Companion
//
//  Created by blaine on 1/15/21.
//

import Foundation

class TimeSeriesMeasurement: Codable, SQLiteTable {
    var id: Int
    let value: Double
    let date: Date
    let dataRead: TimeSeriesDataRead
    var event: SmartPPEEvent?
    
    static var tableName = "time_series_measurement"
    static var createSQL = """
        CREATE TABLE IF NOT EXISTS \(TimeSeriesMeasurement.tableName)(
            id INTEGER PRIMARY KEY NOT NULL,
            value REAL NOT NULL,
            date TEXT NOT NULL,
            data_read_id INTEGER NOT NULL,
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
        dataRead: TimeSeriesDataRead,
        event: SmartPPEEvent?=nil,
        isInserted:Bool=false
    ) {
        self.id = id
        self.value = value
        self.date = date
        self.dataRead = dataRead
        self.event = event
        self.isInserted = isInserted
    }
    
    func insertSQL() -> String {
        
        if event != nil {
            return """
                INSERT INTO \(TimeSeriesMeasurement.tableName)
                (value, date, data_read_id, event_id)
                VALUES (\(value), '\(SQLiteDatabase.dateFormatter.string(from: date))', \(dataRead.id), \(event!.id) );
            """
        } else {
            return """
                INSERT INTO \(TimeSeriesMeasurement.tableName)
                (value, date, data_read_id)
                VALUES (\(value), '\(SQLiteDatabase.dateFormatter.string(from: date))', \(dataRead.id));
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
            (value, date, data_read_id, event_id)
            VALUES
        """
        
        for ts in self {
            if ts.event == nil {
                sql += " (\(ts.value), '\(SQLiteDatabase.dateFormatter.string(from: ts.date))', \(ts.dataRead.id), NULL),"
            } else {
                sql += " (\(ts.value), '\(SQLiteDatabase.dateFormatter.string(from: ts.date))', \(ts.dataRead.id), \(ts.event!.id)),"
            }
        }
        
        sql = String(sql.dropLast())
        sql += ";"
        
        return sql
    }
}
