//
//  DataLoggerViewModel.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
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


class DataViewerViewModel: ObservableObject {
    var appDatabase: AppDatabase
    var facebit: FaceBitPeripheral
    
    @Published var latestTimeSeriesDataRead: TimeSeriesDataRead?
    @Published var latestMetricMeasurement: MetricMeasurement?
    @Published var latestTimestamp: Timestamp?
    @Published var activeEvent: Event?
    
    private var dataReadCancellable: AnyCancellable?
    private var metricMeasurementCancellable: AnyCancellable?
    private var timestampCancellable: AnyCancellable?
    private var eventCancellable: AnyCancellable?
    
    init(appDatabase: AppDatabase, facebit: FaceBitPeripheral) {
        self.appDatabase = appDatabase
        self.facebit = facebit
        
        dataReadCancellable = timeSeriesDataReadPublisher(in: appDatabase)
            .sink { [weak self] dr in
                self?.latestTimeSeriesDataRead = dr
            }
        
        metricMeasurementCancellable = metricMeasurementPublisher(in: appDatabase)
            .sink { [weak self] mm in
                self?.latestMetricMeasurement = mm
            }
        
        timestampCancellable = timestampPublisher(in: appDatabase)
            .sink { [weak self] ts in
                self?.latestTimestamp = ts
            }
        
        eventCancellable = eventPublisher(in: appDatabase)
            .sink { [weak self] e in
                self?.activeEvent = e
            }
    
    }
    
    private func timeSeriesDataReadPublisher(in appDatabase: AppDatabase) -> AnyPublisher<TimeSeriesDataRead?, Never> {
        let pub = ValueObservation
            .tracking(TimeSeriesDataRead.order(TimeSeriesDataRead.Columns.startTime.desc).fetchOne)
            .publisher(in: appDatabase.dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
        
        return pub.catch { error in
            Just<TimeSeriesDataRead?>(nil)
        }
        .eraseToAnyPublisher()
    }
    
    private func metricMeasurementPublisher(in appDatabase: AppDatabase) -> AnyPublisher<MetricMeasurement?, Never> {
        let pub = ValueObservation
            .tracking(MetricMeasurement.order(MetricMeasurement.Columns.date.desc).fetchOne)
            .publisher(in: appDatabase.dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
        
        return pub.catch { error in
            Just<MetricMeasurement?>(nil)
        }
        .eraseToAnyPublisher()
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
    
    private func eventPublisher(in appDatabase: AppDatabase) -> AnyPublisher<Event?, Never> {
        let pub = ValueObservation
            .tracking(
                Event
                    .filter(Event.Columns.endDate == nil)
                    .order(Event.Columns.startDate.desc)
                    .fetchOne
            )
            .publisher(in: appDatabase.dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
        
        return pub.catch { error in
            Just<Event?>(nil)
        }
        .eraseToAnyPublisher()
    }
}
