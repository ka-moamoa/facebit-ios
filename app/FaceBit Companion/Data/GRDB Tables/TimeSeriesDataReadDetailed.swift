//
// Created by blaine on 3/29/21.
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
