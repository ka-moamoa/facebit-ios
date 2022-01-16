//
//  FaceBitConnectionStatusButtonView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//
//  @copyright Copyright (c) 2022 Ka Moamoa
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the license.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
