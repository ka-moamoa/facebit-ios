//
// Created by blaine on 3/29/21.
//

import Foundation
import GRDB

struct TimeSeriesDataReadDetailed: FetchableRecord, MutablePersistableRecord, Codable, Equatable, Identifiable {
    let dataRead: TimeSeriesDataRead
    let measurements: [TimeSeriesMeasurement]
    let event: Event?

    var id: Int64? { return dataRead.id }

    enum CodingKeys: String, CodingKey {
        case dataRead = "time_series_data_read"
        case measurements = "time_series_measurements"
        case event = "event"
    }
}
