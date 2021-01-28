//
//  FaceBitConnectionStatusButtonView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct FaceBitConnectionStatusButtonView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    var icon: some View {
        
        switch facebit.state {
            case .connected:
                return Image(systemName: "link.circle.fill")
        case .disconnected, .notFound:
                return Image(systemName: "link.circle")
        }
    }
    
    var body: some View {
        Button(action: {
            if facebit.state != .connected {
                BluetoothConnectionManager
                    .shared
                    .searchFor(peripheral: facebit)
            } else {
                // todo: disconnect
            }
        }, label: {
            icon
                .font(.system(size: 24.0))
        })
        
    }
}

struct FaceBitConnectionStatusButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FaceBitConnectionStatusButtonView()
    }
}
