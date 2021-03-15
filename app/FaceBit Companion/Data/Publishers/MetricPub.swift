//
//  MetricPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/13/21.
//

import Foundation
import Combine
import SQLite3
import GRDB

class MetricPub: ObservableObject {
    
    @Published var items: [MetricMeasurementInfo] = []
    
    internal var timer: Timer?
    let timerInterval: TimeInterval
    
    let appDatabase: AppDatabase
    let dataType: MetricMeasurement.DataType
    let rowLimit: Int
    
    
    init(appDatabase: AppDatabase, dataType: MetricMeasurement.DataType, rowLimit: Int=1, timerInterval: TimeInterval=10) {
        self.appDatabase = appDatabase
        self.dataType = dataType
        self.rowLimit = rowLimit
        self.timerInterval = timerInterval
    }
    
    func refresh() {
        
        do {
            self.items = try appDatabase.dbWriter.read({ (db) in
                try MetricMeasurement
                    .filter(MetricMeasurement.Columns.dataType == self.dataType.rawValue)
                    .including(optional: MetricMeasurement.event)
                    .asRequest(of: MetricMeasurementInfo.self)
                    .fetchAll(db)
            })
        } catch {
            PersistanceLogger.error("Cannot fetch metrics: \(error.localizedDescription)")
        }
    }
}

extension MetricPub: TimerPublisher {
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
