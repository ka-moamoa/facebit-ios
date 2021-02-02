//
//  GenericEventRecordingView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/28/21.
//

import SwiftUI

struct GenericEventRecordingView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    @State private var activeEvent: SmartPPEEvent?
    @State private var initialized: Bool = false
    
    var body: some View {
        VStack {
            if initialized {
                if activeEvent != nil {
                    ActiveEventView(activeEvent: $activeEvent)
                } else {
                    StartEventView(activeEvent: $activeEvent)
                }
            }else {
                Text("Checking for Active Event ...")
            }
        }
        .padding()
        .navigationTitle("Event Recording")
        .navigationBarItems(trailing:
            FaceBitConnectionStatusButtonView()
        )
        .onAppear(perform: {
            initialized = false
            SmartPPEEvent.getActiveEvent(callback: { (event) in
                self.activeEvent = event
                self.initialized = true
            })
        })
    }
}

struct GenericEventRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        GenericEventRecordingView()
    }
}
