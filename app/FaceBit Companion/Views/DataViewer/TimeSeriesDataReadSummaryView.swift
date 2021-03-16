//
//  DataReadSummaryView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI

struct TimeSeriesDataReadSummaryView: View {
    var dataRead: TimeSeriesDataRead
    
    var body: some View {
        Text("\(dataRead.startTime)")
    }
}

struct DataReadSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSeriesDataReadSummaryView(
            dataRead: TimeSeriesDataRead(
                id: nil,
                dataType: .pressure,
                frequency: 25.0,
                millisecondOffset: 100,
                startTime: Date(),
                numSamples: 100
            )
        )
    }
}
