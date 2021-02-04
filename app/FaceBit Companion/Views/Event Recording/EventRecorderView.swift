//
//  EventRecorderView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/19/21.
//

import SwiftUI
import Combine

extension SmartPPEEventType {
    @ViewBuilder func view(facebit: FaceBitPeripheral) -> some View {
        switch self {
        case .normalBreathing: NormalBreathingEventRecordView(facebit: facebit)
        case .deepBreathing: DeepBreathingEventRecordView()
        case .talking: TalkingEventRecordView()
        case .cough: CoughEventRecordView()
        case .other: Text("TODO:")
        }
    }
}

struct EventRecorderView: View {
    @State var facebit: FaceBitPeripheral
    @State private var event: SmartPPEEventType = .normalBreathing
    
    var body: some View {
        VStack {
            Picker("Event", selection: $event) {
                ForEach(SmartPPEEventType.allCases) { e in
                    Text(e.rawValue.capitalized)
                        .tag(e)
                        .font(.subheadline)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Spacer()
            
            event.view(facebit: facebit)
            
            Spacer()
        }
        .navigationTitle("Record Event")
    }
}

struct EventRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        EventRecorderView(facebit: FaceBitPeripheral(readChars: []))
    }
}
