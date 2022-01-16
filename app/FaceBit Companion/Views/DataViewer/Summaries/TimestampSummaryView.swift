//
//  TimestampSummaryView.swift
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

struct TimestampSummaryView: View {
    var timestamp: Timestamp
    
    
    var body: some View {
        VStack(alignment: .leading) {
            DataSummaryFieldView(
                title: "Name",
                value: "\(timestamp.name ?? "")"
            )
            
            DataSummaryFieldView(
                title: "Id",
                value: "\(timestamp.id ?? -1)"
            )
            
            DataSummaryFieldView(
                title: "Data Type",
                value: "\(timestamp.dataType.rawValue)"
            )
            
            DataSummaryFieldView(
                title: "Date",
                value: "\(timestamp.date)"
            )
            
            DataSummaryFieldView(
                title: "Event Id",
                value: "\(timestamp.eventId ?? -1)"
            )
        }
        
    }
}

struct TimestampSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        TimestampSummaryView(
            timestamp: Timestamp(
                id: nil,
                dataType: .peripheralSync,
                date: Date()
            )
        )
    }
}
