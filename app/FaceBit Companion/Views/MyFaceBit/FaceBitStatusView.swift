//
//  FaceBitStatus.swift
//  FaceBit Companion
//
//  Created by blaine on 1/18/21.
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

struct FaceBitStatusView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }
    
    var activeMsg: String {
        var activeMsg = "Inactive"
        if facebit.state == .connected {
            activeMsg = "Active"
        
        } else if facebit.lastContact != nil, facebit.lastContact! > Date() - (60*5) {
            activeMsg = "Last Active \(dateFormatter.string(from: facebit.lastContact!))"
        }
        
        return activeMsg
    }
    
    var activeImageName: String {
        switch activeMsg {
        case "Inactive":
            return "exclamationmark.circle"
        default:
            return "checkmark"
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            FaceBitIcon()
                .frame(width: 75, height: 75, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4.0) {
                HStack {
                    Image(systemName: "tag")
                        .font(.system(size: 18.0))
                        .foregroundColor(Color("PrimaryOrange"))
                    Text(facebit.name)
                }
                HStack {
                    Image(systemName: activeImageName)
                        .font(.system(size: 18))
                        .foregroundColor(Color("PrimaryOrange"))
                    Text(activeMsg)
                }
//                HStack {
//                    Image(systemName: "clock")
//                        .font(.system(size: 18))
//                        .foregroundColor(Color("PrimaryOrange"))
//                    Text("43 minutes wear time")
//                }
            }
            .font(.system(size: 14.0))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 30))
        }
    }
}

struct FaceBitStatus_Previews: PreviewProvider {
    static var previews: some View {
        FaceBitStatusView()
    }
}
