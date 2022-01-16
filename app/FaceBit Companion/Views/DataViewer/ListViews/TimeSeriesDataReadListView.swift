//
//  TimeSeriesDataReadListView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
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

import SwiftUI
import GRDB

struct TimeSeriesDataReadListView: View {
    @State var latestDataRead: TimeSeriesDataRead?
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: TimeSeriesDataRead
                            .including(all: TimeSeriesDataRead.measurements)
                            .including(optional: TimeSeriesDataRead.event)
                            .order(Column("id").desc)
                            .asRequest(of: TimeSeriesDataReadDetailed.self)
                ),
                rowBuilder: { info in return TimeSeriesDataReadSummaryView(dataRead: info.dataRead) },
                title: "Time Series Data Reads"
            ),
            label: {
                Text("TimeSeries Data Read")
            })
    }
}

struct TimeSeriesDataReadListView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSeriesDataReadListView()
    }
}
