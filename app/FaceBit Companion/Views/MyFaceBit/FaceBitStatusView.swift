//
//  FaceBitStatus.swift
//  FaceBit Companion
//
//  Created by blaine on 1/18/21.
//

import SwiftUI

struct FaceBitStatusView: View {
    @StateObject var facebit: FaceBitPeripheral
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            Image(systemName: "face.smiling.fill")
                .font(.system(size: 60))
                .border(Color.black, width: 1)
            VStack(alignment: .leading, spacing: 8.0) {
                HStack {
                    Image(systemName: "tag")
                    Text("My Facebit Name")
                }
                HStack {
                    Image(systemName: "checkmark")
                    Text("Active, a few seconds ago")
                }
                HStack {
                    Image(systemName: "clock")
                    Text("43 minutes wear time")
                }
            }
            .font(.system(size: 14.0))
            
            Image(systemName: "chevron.right")
                .font(.system(size: 60))
        }
        
    }
}

struct FaceBitStatus_Previews: PreviewProvider {
    static var previews: some View {
        FaceBitStatusView(facebit: FaceBitPeripheral())
    }
}
