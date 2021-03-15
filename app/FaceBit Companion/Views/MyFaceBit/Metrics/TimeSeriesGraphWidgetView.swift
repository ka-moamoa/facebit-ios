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
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(title: String, dataType: TimeSeriesDataRead.DataType, timerInterval: TimeInterval, rowLimit: Int, timeOffset: TimeInterval) {
        
        self.title = title
        self.publisher = TimeSeriesMeasurementPub(
            appDatabase: AppDatabase.shared,
            dataType: dataType,
            rowLimit: rowLimit,
            timerInterval: timerInterval,
            timeOffset: timeOffset
        )
        
        publisher.refresh()
    }
    
    var body: some View {
        WidgetView {
            VStack {
                Text(title)
                    .bold()
                LiveLinePlot(timeSeries: $publisher.items, showAxis: false)
            }
        }
        .onLoad() {
            setRefresh(facebit.state)
            publisher.refresh()
        }
        .onAppear() { setRefresh(facebit.state) }
        .onDisappear() { publisher.stop() }
        .onReceive(facebit.$state.dropFirst()) { state in
            setRefresh(state)
        }
    }
    
    func setRefresh(_ state: PeripheralState) {
        if state == .connected {
            publisher.start()
        } else {
            publisher.stop()
        }
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
