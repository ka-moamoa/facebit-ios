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
    
    let dataType: TimeSeriesDataRead.DataType
    let rowLimit: Int
    let timerInterval: TimeInterval
    let timeOffset: TimeInterval
    
    internal var query: String {
        let beforeDate = SQLiteDatabase.dateFormatter.string(
            from: Date().addingTimeInterval(-timeOffset)
        )
        
        return """
            SELECT ts.id, ts.value, ts.date, ts.data_read_id, ts.event_id, read.data_type
            FROM \(TimeSeriesMeasurement.tableName) as ts
            JOIN \(TimeSeriesDataRead.tableName) as read ON ts.data_read_id = read.id
            WHERE read.data_type = '\(dataType.rawValue)'
                AND ts.date < '\(beforeDate)'
            ORDER BY date DESC
            LIMIT \(rowLimit);
        """
    }
    
    internal var timer: Timer?
    
    init(dataType: TimeSeriesDataRead.DataType, rowLimit: Int=100, timerInterval: TimeInterval=0.1, timeOffset: TimeInterval=4) {
        self.dataType = dataType
        self.rowLimit = rowLimit
        self.timerInterval = timerInterval
        self.timeOffset = timeOffset
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
            var dataReads = [Int:TimeSeriesDataRead]()
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let value = sqlite3_column_double(statement, 1)
                let dataReadId = Int(sqlite3_column_int(statement, 3))
                
                guard let dateCString = sqlite3_column_text(statement, 2),
                      let date = SQLiteDatabase.dateFormatter.date(from: String(cString: dateCString)) else {
                    continue
                }
                
                if dataReads[dataReadId] == nil {
                    if let dataRead = TimeSeriesDataRead.get(by: dataReadId) {
                        dataReads[dataReadId] = dataRead
                    } else { continue }
                }
                
                measurements.append(
                    TimeSeriesMeasurement(
                        id: id,
                        value: value,
                        date: date,
                        dataRead: dataReads[dataReadId]!,
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

extension TimeSeriesMeasurementPub: TimerPublisher {
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
}
