//
//  TimeSeriesMeasurementPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/2/21.
//

import Foundation
import Combine
import SQLite3
import GRDB


class TimeSeriesMeasurementPub: ObservableObject {
    @Published var items: [TimeSeriesMeasurementInfo] = []
    
    let appDatabase: AppDatabase
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
    
    init(
        appDatabase: AppDatabase,
        dataType: TimeSeriesDataRead.DataType,
        rowLimit: Int=100,
        timerInterval: TimeInterval=0.1,
        timeOffset: TimeInterval=4
    ) {
        
        self.appDatabase = appDatabase
        self.dataType = dataType
        self.rowLimit = rowLimit
        self.timerInterval = timerInterval
        self.timeOffset = timeOffset
    }
    
    func refresh() {
        do {
            self.items = try appDatabase.dbWriter.read { (db) in
                let req = TimeSeriesMeasurement_New
                    .filter(Column("date") < Date().addingTimeInterval(-timeOffset))
                    .including(optional: TimeSeriesMeasurement_New.event)
                    .including(
                        required: TimeSeriesMeasurement_New.dataRead.filter(Column("data_type") == dataType.rawValue)
                    )
                    .asRequest(of: TimeSeriesMeasurementInfo.self)
                
                return try req.fetchAll(db)
            }
        } catch {

        }
        
//        SQLiteDatabase.queue.async {
//            guard let db = SQLiteDatabase.main,
//                let statement = try? db.prepareStatement(sql: self.query, dbPointer: db.dbPointer) else {
//                return
//            }
//
//            defer {
//                sqlite3_finalize(statement)
//            }
//
//            var measurements: [TimeSeriesMeasurement] = []
//            var dataReads = [Int:TimeSeriesDataRead]()
//
//            while sqlite3_step(statement) == SQLITE_ROW {
//                let id = Int(sqlite3_column_int(statement, 0))
//                let value = sqlite3_column_double(statement, 1)
//                let dataReadId = Int(sqlite3_column_int(statement, 3))
//
//                guard let dateCString = sqlite3_column_text(statement, 2),
//                      let date = SQLiteDatabase.dateFormatter.date(from: String(cString: dateCString)) else {
//                    continue
//                }
//
//                if dataReads[dataReadId] == nil {
//                    if let dataRead = TimeSeriesDataRead.get(by: dataReadId, dbPointer: db.dbPointer) {
//                        dataReads[dataReadId] = dataRead
//                    } else { continue }
//                }
//
//                measurements.append(
//                    TimeSeriesMeasurement(
//                        id: id,
//                        value: value,
//                        date: date,
//                        dataRead: dataReads[dataReadId]!,
//                        isInserted: true
//                    )
//                )
//            }
//
//            DispatchQueue.main.async {
//                self.items = measurements
//            }
//        }
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
