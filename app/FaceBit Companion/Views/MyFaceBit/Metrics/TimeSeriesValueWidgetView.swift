//
//  TimeSeriesValueWidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/2/21.
//

import SwiftUI

struct TimeSeriesValueWidgetView: View {
    private var title: String
    private var unit: String
    @ObservedObject var publisher: TimeSeriesMeasurementPub
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(
        title: String,
        unit: String,
        dataType: TimeSeriesMeasurement.DataType,
        timerInterval: TimeInterval,
        rowLimit: Int,
        timeOffset: TimeInterval
    ) {
        
        self.title = title
        self.unit = unit
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
                Text("\(String(format: "%.2f", publisher.items.first?.value ?? 0.0))")
                    .font(.system(size: 32.0))
                Text(unit)
            }
        }
        .onAppear(perform: { setRefresh(facebit.state) })
        .onDisappear(perform: { publisher.stop() })
        .onReceive(facebit.$state, perform: { state in
            setRefresh(state)
        })
    }
    
    func setRefresh(_ state: PeripheralState) {
        if state == .connected {
            publisher.start()
        } else {
            publisher.stop()
            publisher.refresh()
        }
    }
}

struct TimeSeriesValueWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSeriesValueWidgetView(
            title: "Time Series",
            unit: "Units",
            dataType: .temperature,
            timerInterval: 1,
            rowLimit: 25,
            timeOffset: 2
        )
    }
}