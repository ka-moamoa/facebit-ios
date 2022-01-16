//
//  MaskWearTimeVIew.swift
//  FaceBit Companion
//
//  Created by blaine on 2/14/21.
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

struct MaskWearTimeView: View {
    @EnvironmentObject var maskVM: MaskViewModel
    @State private var value: Float = 0.45
    
    @State private var selectedWearTime: Float = 8.0
    
    private var percentFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.percentSymbol = "％"
        formatter.numberStyle = .percent
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }
 
    var body: some View {
        if let mask = maskVM.mask {
            VStack {
                VStack(alignment: .leading, spacing: 16.0) {
                    Text("\(mask.maskType.rawValue) Mask")
                        .font(.title2)
                    Text("You started using this mask on \(dateFormatter.string(from: mask.startDate))")
                    Divider()
                    Text("Mask Progress")
                        .font(.title2)
                    Text("\(mask.wearTimeString) Total Wear Time")
                    Text("\(percentFormatter.string(from: NSNumber(value: mask.percentValue)) ?? "0%") of suggest maximum wear time")
                    VStack(spacing: 4.0) {
                        ProgressBar(value: mask.percentValue)
                            .frame(height: 20.0)
                            .padding(16.0)
                            .accentColor(.red)
                        HStack{
                            Text("0H")
                            Spacer()
                            Text("\(maskVM.mask?.desiredWearHours ?? 0)H")
                        }
                    }
                    Spacer()
                }
                .padding(16)
                PrimaryButton(
                    action: { maskVM.disposeMask() },
                    content: { Text("Dispose Mask") }
                )
            }
            .padding(16.0)
        } else {
            VStack (spacing: 16.0) {
                HStack {
                    FaceBitIcon()
                        .frame(width: 75.0, height: 75.0)
                    Text("What type of mask are you wearing?")
                        .font(.title)
                }
                Text("There is currently no mask being tracked, let's create one")
                    .font(.subheadline)
                VStack(spacing: 32.0) {
                    Text("Desired Wear Time: \(Int(selectedWearTime)) Hours")
                        .bold()
                    HStack{
                        Text("2hrs")
                        Slider(
                            value: $selectedWearTime,
                            in: 2...24,
                            step: 1.0
                        )
                        Text("24hrs")
                    }
                    ForEach(Mask.MaskType.allCases, id: \.self) { (maskType) in
                        PrimaryButton(
                            action: { maskVM.createMask(of: maskType, wearHours: Int(selectedWearTime)) },
                            content: { Text(maskType.rawValue) }
                        )
                        .frame(maxWidth: .infinity)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(16)
        }
    }
}

struct MaskWearTimeView_Previews: PreviewProvider {
    
    static var previews: some View {
        MaskWearTimeView()
    }
}
