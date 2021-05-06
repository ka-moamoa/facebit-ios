//
//  EventDetailed.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import Foundation
import GRDB

struct EventDetailed: FetchableRecord, Codable, Equatable, Identifiable {
    var event: Event
    var timeSeriesMeasurements: [TimeSeriesMeasurement]
    var timeSeriesDataReads: [TimeSeriesDataRead]
    var metrics: [MetricMeasurement]
    var timestamps: [Timestamp]
    
    var id: Int64? { return event.id }
    
    enum CodingKeys: String, CodingKey {
        case event = "event"
        case timeSeriesMeasurements = "time_series_measurements"
        case timeSeriesDataReads = "time_series_data_reads"
        case metrics = "metric_measurements"
        case timestamps = "timestamps"
    }
}
