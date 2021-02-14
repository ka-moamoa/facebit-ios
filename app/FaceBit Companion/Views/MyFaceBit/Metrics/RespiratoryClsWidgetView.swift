//
//  RespiratoryClsWidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/11/21.
//

import SwiftUI

struct RespiratoryClsWidgetView: View {
    @ObservedObject private var publisher: RespitoryClassifierPub
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(timeOffset: TimeInterval=5, timerInterval: TimeInterval = 25) {
        self.publisher = RespitoryClassifierPub(
            timeOffset: timeOffset,
            timerInterval: timerInterval
        )
    }
    
    var body: some View {
        WidgetView {
            VStack {
                Text("Resp. Class.")
                    .bold()
                Spacer()
                Text(publisher.classification.label)
                    .font(.system(size: 32.0))
                Spacer()
            }
        }
        .onAppear(perform: { setRefresh(facebit.state) })
        .onDisappear(perform: { publisher.stop() })
        .onReceive(facebit.$state.dropFirst(), perform: { state in
            setRefresh(state)
        })
    }
    
    func setRefresh(_ state: PeripheralState) {
        if state == .connected {
            publisher.start()
        } else {
            publisher.stop()
        }
    }
}

struct RespiratoryClsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        RespiratoryClsWidgetView()
    }
}
