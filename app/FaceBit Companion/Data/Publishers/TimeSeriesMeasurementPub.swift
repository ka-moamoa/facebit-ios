//
//  TimeSeriesMeasurementPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/2/21.
//

import Foundation
import Combine
import SQLite3

class TimeSeriesMeasurementPub: DatabasePublisher, ObservableObject {
    
    @Published var items: [TimeSeriesMeasurement] = []
    
    let dataType: TimeSeriesMeasurement.DataType
    let rowLimit: Int
    let timerInterval: TimeInterval
    let timeOffset: TimeInterval
    
    internal var query: String {
        let beforeDate = SQLiteDatabase.dateFormatter.string(
            from: Date().addingTimeInterval(-timeOffset)
        )
        
        return """
            SELECT id, value, date, type, event_id
            FROM \(TimeSeriesMeasurement.tableName)
            WHERE type = '\(dataType.rawValue)'
                AND date < '\(beforeDate)'
            ORDER BY date DESC
            LIMIT \(rowLimit);
        """
    }
    
    internal var timer: Timer?
    
    init(dataType: TimeSeriesMeasurement.DataType, rowLimit: Int=100, timerInterval: TimeInterval=0.1, timeOffset: TimeInterval=4) {
        self.dataType = dataType
        self.rowLimit = rowLimit
        self.timerInterval = timerInterval
        self.timeOffset = timeOffset
    }
    
    func start() {
        timer = Timer.scheduledTimer(
            withTimeInterval: timerInterval,
            repeats: true,
            block: onFire
        )
        timer!.fire()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    internal func onFire(_ timer: Timer) {
        DispatchQueue.main.async { self.refresh() } 
    }
    
    func refresh() {
        SQLiteDatabase.queue.async {
            guard let db = SQLiteDatabase.main,
                  let statement = try? db.prepareStatement(sql: self.query) else {
                return
            }
            
            defer {
                sqlite3_finalize(statement)
            }
            
            var measurements: [TimeSeriesMeasurement] = []
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let value = sqlite3_column_double(statement, 1)
                
                guard let dateCString = sqlite3_column_text(statement, 2),
                      let typeCString = sqlite3_column_text(statement, 3),
                      let date = SQLiteDatabase.dateFormatter.date(from: String(cString: dateCString)),
                      let type = TimeSeriesMeasurement.DataType(rawValue: String(cString: typeCString)) else {
                    continue
                }
                
                measurements.append(
                    TimeSeriesMeasurement(
                        id: id,
                        value: value,
                        date: date,
                        type: type,
                        isInserted: true
                    )
                )
            }
            
            DispatchQueue.main.async {
                self.items = measurements
            }
        }
    }
}
