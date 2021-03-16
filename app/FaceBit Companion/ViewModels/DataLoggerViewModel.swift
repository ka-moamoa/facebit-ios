//
//  DataLoggerViewModel.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import Foundation
import Combine
import GRDB


class DataLoggerViewModel: ObservableObject {
    var appDatabase: AppDatabase
    var facebit: FaceBitPeripheral
    
    @Published var dataReads: [TimeSeriesDataRead] = []
    
    private var dataReadCancellable: AnyCancellable?
    
    init(appDatabase: AppDatabase, facebit: FaceBitPeripheral) {
        self.appDatabase = appDatabase
        self.facebit = facebit
        
        dataReadCancellable = timeSeriesDataReadPublisher(in: appDatabase)
            .scan([]) { (previousDataReads: [TimeSeriesDataRead]?, newDataReads: [TimeSeriesDataRead]) in
                return newDataReads
            }
            .sink { [weak self] dataReads in
                self?.dataReads = dataReads
            }
    }
    
    func timeSeriesDataReadPublisher(in appDatabase: AppDatabase) -> AnyPublisher<[TimeSeriesDataRead], Never> {
        let pub = ValueObservation
            .tracking(TimeSeriesDataRead.all().order(TimeSeriesDataRead.Columns.startTime.desc).fetchAll)
            .publisher(in: appDatabase.dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
        
        return pub.catch { error in
            Just<[TimeSeriesDataRead]>([])
        }
        .eraseToAnyPublisher()
    }
}
