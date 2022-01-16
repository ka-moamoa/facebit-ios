//
//  FaceBitDetailsViewModel.swift
//  FaceBit Companion
//
//  Created by blaine on 3/18/21.
//
//  @copyright Copyright (c) 2022 Ka Moamoa
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the license.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
