//
//  FaceBitDetailsView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/12/21.
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

struct FaceBitDetailsView: View {
    
    @ObservedObject var facebit: FaceBitPeripheral
    @ObservedObject var bleManager: BluetoothConnectionManager
    @ObservedObject var viewModel: FaceBitDetailsViewModel
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }
    
    private var lastDateText: String {
        guard let ts = viewModel.latestTimestamp else {
            return "Never"
        }
        
        return dateFormatter.string(from: ts.date)
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
        FaceBitDetailsView(
            facebit: FaceBitPeripheral(readChars: []),
            bleManager: BluetoothConnectionManager.shared,
            viewModel: FaceBitDetailsViewModel(appDatabase: AppDatabase.shared)
            )
    }
}
