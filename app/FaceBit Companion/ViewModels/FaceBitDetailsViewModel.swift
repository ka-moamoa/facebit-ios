//
//  FaceBitDetailsViewModel.swift
//  FaceBit Companion
//
//  Created by blaine on 3/18/21.
//

import Foundation
import Combine
import GRDB

class FaceBitDetailsViewModel: ObservableObject {
    private var appDatabase: AppDatabase
    
    @Published var latestTimestamp: Timestamp?
    
    private var timestampCancellable: AnyCancellable?
    
    
    init(appDatabase: AppDatabase) {
        self.appDatabase = appDatabase
        
        timestampCancellable = timestampPublisher(in: appDatabase)
            .sink { [weak self] ts in
                self?.latestTimestamp = ts
            }
    }
    
    private func timestampPublisher(in appDatabase: AppDatabase) -> AnyPublisher<Timestamp?, Never> {
        let pub = ValueObservation
            .tracking(Timestamp.order(Timestamp.Columns.date.desc).fetchOne)
            .publisher(in: appDatabase.dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
        
        return pub.catch { error in
            Just<Timestamp?>(nil)
        }
        .eraseToAnyPublisher()
    }
}
