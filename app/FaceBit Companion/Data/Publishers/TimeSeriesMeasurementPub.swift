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
                let req = TimeSeriesMeasurement
                    .filter(Column("date") < Date().addingTimeInterval(-timeOffset))
                    .including(optional: TimeSeriesMeasurement.event)
                    .including(
                        required: TimeSeriesMeasurement.dataRead.filter(Column("data_type") == dataType.rawValue)
                    )
                    .asRequest(of: TimeSeriesMeasurementInfo.self)
                
                return try req.fetchAll(db)
            }
        } catch {

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
