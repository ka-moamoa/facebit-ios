//
//  MetricMeasurementInfo.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import Foundation
import GRDB


struct MetricMeasurementDetailed: FetchableRecord, MutablePersistableRecord, Codable, Identifiable {
    let metric: MetricMeasurement
    let event: Event?
    
    var id: Int64? { return metric.id }
    
    enum CodingKeys: String, CodingKey {
        case metric = "metric_measurement"
        case event = "event"
    }
}
