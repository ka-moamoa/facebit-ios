//
//  FaceBitDetailsView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/12/21.
//

import SwiftUI

struct FaceBitDetailsView: View {
    
    @EnvironmentObject var facebit: FaceBitPeripheral
    @ObservedObject var bleManager: BluetoothConnectionManager = BluetoothConnectionManager.shared
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }
    
    private var lastDateText: String {
        if facebit.state == .connected {
        return "Now"
        }
        
        if let lastContact = facebit.lastContact {
            return dateFormatter.string(from: lastContact)
        }
        
        return "Never"
    }
    
    var body: some View {
        ScrollView {
            VStack {
                FaceBitIcon()
                    .frame(width: 150, height: 150, alignment: .center)
                Text(facebit.name)
                    .font(.headline)
                Divider()
                
                VStack(spacing: 16.0) {
                    HStack {
                        Text("Connection Status:")
                            .bold()
                        Spacer()
                        Text("\(facebit.state.rawValue.capitalized)")
                    }
                    
                    HStack {
                        Text("Last Contact:")
                            .bold()
                        Spacer()
                        Text(lastDateText)
                    }
                    
                    HStack {
                        Text("Available Metrics:")
                            .bold()
                        Spacer()
                        Text(facebit.readChars.map({ $0.name }).joined(separator: ", "))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Divider()
                Spacer()
                PrimaryButton(
                    action: {
                        if facebit.state == .connected {
                            bleManager.disconnect(facebit)
                        } else if bleManager.isScanning {
                            bleManager.stopScan()
                        } else {
                            bleManager.searchFor(peripheral: facebit)
                        }
                    }, content: {
                        Group {
                            if facebit.state == .connected {
                                Text("Disconnect")
                            } else if bleManager.isScanning {
                                Text("Stop Scanning")
                            } else {
                                Text("Start Scanning")
                            }
                        }
                    })
            }
            .padding(16)
        }
        .navigationTitle("My FaceBit Details")
        
    }
}

struct FaceBitDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        FaceBitDetailsView()
    }
}
