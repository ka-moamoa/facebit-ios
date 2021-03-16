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
        Text("\(timestamp.date)")
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
