//
//  FaceBitStatus.swift
//  FaceBit Companion
//
//  Created by blaine on 1/18/21.
//

import SwiftUI

struct FaceBitStatusView: View {
    @ObservedObject var facebit: FaceBitPeripheral
    
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
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            Image("face-mask")
                .resizable()
                .padding(2.0)
                .frame(width: 75, height: 75, alignment: .center)
                .scaledToFill()
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(lineWidth: 2.0)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4.0) {
                HStack {
                    Image(systemName: "tag")
                        .font(.system(size: 18.0))
                        .foregroundColor(.blue)
                    Text(facebit.name)
                }
                HStack {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                    Text(activeMsg)
                }
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                    Text("43 minutes wear time")
                }
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
        FaceBitStatusView(facebit: FaceBitPeripheral())
    }
}
