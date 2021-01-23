//
//  NormalBreathingEventRecordView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/19/21.
//

import SwiftUI
import Combine

struct NormalBreathingEventRecordView: View {
    @State var facebit: FaceBitPeripheral
    @State private var isStarted: Bool = false
    @State private var timeRemaining = 30
    @State private var startCountdown = 3
    
    @State private var event: SmartPPEEvent?
    
    var timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var body: some View {
        VStack {
            Text("Normal Breathing Event Recording")
                .font(.title)
            Text("Breath normally for 30 seconds. Try not to talk or move for the duration.")
                .font(.body)
            Divider()
            Spacer()
            if isStarted {
                if startCountdown > 0 {
                    Text("Start in")
                        .font(.system(size: 28))
                    Text("\(startCountdown)")
                        .font(.system(size: 72))
                        .padding(32.0)
                    
                } else {
                    Text("Continue to breathe normally")
                        .font(.title)
                    Text("\(timeRemaining)")
                        .font(.system(size: 72))
                        .padding(32.0)
                    
                }
            } else {
                Button(action: {
                    self.isStarted = true
                    self.startCountdown = 3
                    self.timeRemaining = 30
                    self.event = SmartPPEEvent(eventType: .normalBreathing)
                    try? SQLiteDatabase.main?.insertRecord(record: self.event!)
                }, label: {
                    Text("Start")
                        .font(.title)
                        .padding(16.0)
                })
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.gray)
                )
            }
            Spacer()
        }
        .onReceive(timer, perform: { _ in
            guard isStarted else { return }
            
            if self.startCountdown > 0 { self.startCountdown -= 1 }
            if self.startCountdown == 0 {
                if self.event?.startDate == nil { self.event?.start() }
                self.facebit.setEvent(self.event!)
                if self.timeRemaining > 0 { self.timeRemaining -= 1 }
                if self.timeRemaining == 0 {
                    isStarted = false
                    self.facebit.setEvent()
                    self.event?.end()
                }
            }
        })
    }
}

struct NormalBreathingEventRecordView_Previews: PreviewProvider {
    static var previews: some View {
        NormalBreathingEventRecordView(facebit: FaceBitPeripheral())
    }
}
