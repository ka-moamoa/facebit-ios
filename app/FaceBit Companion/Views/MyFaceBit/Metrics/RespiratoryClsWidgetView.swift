//
//  RespiratoryClsWidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/11/21.
//

import SwiftUI

struct RespiratoryClsWidgetView: View {
    @ObservedObject private var pub = RespitoryClassifierPub(timeOffset: 5, timerInterval: 5)
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    var body: some View {
        WidgetView {
            VStack {
                Text("Resp. Class.")
                    .bold()
                Spacer()
                Text(pub.classification.label)
                    .font(.system(size: 32.0))
                Spacer()
            }
        }
        .onAppear(perform: { setRefresh(facebit.state) })
        .onDisappear(perform: { pub.stop() })
        .onReceive(facebit.$state, perform: { state in
            setRefresh(state)
        })
    }
    
    func setRefresh(_ state: PeripheralState) {
        if state == .connected {
            pub.start()
        } else {
            pub.stop()
            pub.fetchData()
        }
    }
}

struct RespiratoryClsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        RespiratoryClsWidgetView()
    }
}
