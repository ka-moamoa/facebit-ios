//
//  RawPressure.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct TimeSeriesGraphWidgetView: View {
    var title: String
    @ObservedObject var publisher: TimeSeriesMeasurementPub
    
    init(title: String, dataType: TimeSeriesDataRead.DataType, timerInterval: TimeInterval, rowLimit: Int, timeOffset: TimeInterval) {
        
        self.title = title
        self.publisher = TimeSeriesMeasurementPub(
            dataType: dataType,
            rowLimit: rowLimit,
            timerInterval: timerInterval,
            timeOffset: timeOffset
        )
    }
    
    var body: some View {
        WidgetView {
            VStack {
                Text(title)
                    .bold()
                LiveLinePlot(timeSeries: $publisher.items, showAxis: false)
            }
        }
        .onAppear(perform: {
            publisher.start()
        })
        .onDisappear(perform: {
            publisher.stop()
        })
    }
}

struct RawPressure_Previews: PreviewProvider {
    
    static var previews: some View {
        TimeSeriesGraphWidgetView(
            title: "Time Series",
            dataType: .temperature,
            timerInterval: 1,
            rowLimit: 25,
            timeOffset: 2
        )
    }
}
