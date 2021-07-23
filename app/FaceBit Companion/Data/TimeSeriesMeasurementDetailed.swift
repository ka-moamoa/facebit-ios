//
//  TimeSeriesMeasurementInfo.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import Foundation
import GRDB

struct TimeSeriesMeasurementDetailed: FetchableRecord, MutablePersistableRecord, Codable, Equatable, Identifiable {
    var timeSeriesMeasurement: TimeSeriesMeasurement
    var dataRead: TimeSeriesDataRead
    var event: Event?
    
    var id: Int64? { return timeSeriesMeasurement.id }
    
    enum CodingKeys: String, CodingKey {
        case timeSeriesMeasurement = "time_series_measurement"
        case dataRead = "time_series_data_read"
        case event = "event"
    }
}
