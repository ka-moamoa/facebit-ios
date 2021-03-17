//
//  TimestampSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI

struct TimestampSummaryView: View {
    var timestamp: Timestamp
    
    
    var body: some View {
        VStack(alignment: .leading) {
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
