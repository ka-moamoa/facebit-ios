//
//  TimestampListView.swift
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

import SwiftUI

struct TimestampListView: View {
    @State var latestTimestamp: Timestamp?
    
    var body: some View {
        NavigationLink(
            destination: DataListView(
                viewModel: DatabaseTableViewModel(
                    appDatabase: AppDatabase.shared,
                    request: Timestamp.all()
                ),
                rowBuilder: { ts in TimestampSummaryView(timestamp: ts) },
                title: "Timestamps"
            ),
            label: {
                Text("Timestamps")
            }
        )
    }
}

struct TimestampListView_Previews: PreviewProvider {
    static var previews: some View {
        TimestampListView(
            latestTimestamp: Timestamp(id: 0, dataType: .peripheralSync, date: Date()))
    }
}
