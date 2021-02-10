//
//  DataRead.swift
//  FaceBit Companion
//
//  Created by blaine on 2/9/21.
//

import Foundation
import SQLite3

class TimeSeriesDataRead: Codable, SQLiteTable {
    enum DataType: String, Codable {
        case none = "none"
        case pressure = "pressure"
        case temperature = "temperature"
    }
    
    static var memId: MemoryId = MemoryId()
    static var createSQL: String = """
        CREATE TABLE IF NOT EXISTS \(TimeSeriesDataRead.tableName)(
            id INTEGER PRIMARY KEY NOT NULL,
            data_type TEXT NOT NULL,
            frequency REAL NOT NULL,
            millisecond_offset INTEGER NOT NULL,
            num_samples INTEGER NOT NULL,
            start_time TEXT NOT NULL
        );
    """
    
    static var tableName: String = "time_series_data_read"
    
    var id: Int
    let dataType: DataType
    let frequency: Double
    let millisecondOffset: Int
    let startTime: Date
    let numSamples: Int
    
    var isInserted: Bool
    
    init(
        id:Int=memId.next,
        dataType: DataType,
        frequency: Double,
        millisecondOffset: Int,
        startTime: Date,
        numSamples: Int,
        isInserted: Bool=false
    ) {
        self.id = id
        self.dataType = dataType
        self.frequency = frequency
        self.millisecondOffset = millisecondOffset
        self.startTime = startTime
        self.numSamples = numSamples
        self.isInserted = isInserted
    }
    
    
    func insertSQL() -> String {
        return """
            INSERT INTO \(TimeSeriesDataRead.tableName)
            (data_type, frequency, millisecond_offset, num_samples, start_time)
            VALUES ('\(dataType.rawValue)', \(frequency), \(millisecondOffset), \(numSamples), '\(SQLiteDatabase.dateFormatter.string(from: startTime))');
        """
    }
    
    func didInsert(id: Int) {
        self.isInserted = true
        self.id = id
    }

}

extension TimeSeriesDataRead {
    static func get(by id: Int) -> TimeSeriesDataRead? {
        let query = """
            SELECT id, data_type, frequency, millisecond_offset, num_samples, start_time
            FROM \(TimeSeriesDataRead.tableName)
            WHERE id = \(id)
        """
        
        guard let db = SQLiteDatabase.main,
              let statement = try? db.prepareStatement(sql: query) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let frequency = sqlite3_column_double(statement, 2)
            let millisecondOffset = Int(sqlite3_column_int(statement, 3))
            let numSamples = Int(sqlite3_column_int(statement, 4))
            
            guard let startTimeCString = sqlite3_column_text(statement, 5),
                  let typeCString = sqlite3_column_text(statement, 1),
                  let startTime = SQLiteDatabase.dateFormatter.date(from: String(cString: startTimeCString)),
                  let dataType = TimeSeriesDataRead.DataType(rawValue: String(cString: typeCString)) else {
                return nil
            }
            
            let dataRead = TimeSeriesDataRead(
                id: id,
                dataType: dataType,
                frequency: frequency,
                millisecondOffset: millisecondOffset,
                startTime: startTime,
                numSamples: numSamples,
                isInserted: true
            )
            return dataRead
        }
        return nil
    }
}
