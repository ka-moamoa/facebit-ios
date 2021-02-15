//
//  MaskWearTimeVIew.swift
//  FaceBit Companion
//
//  Created by blaine on 2/14/21.
//

import SwiftUI

struct MaskWearTimeView: View {
    @EnvironmentObject var maskVM: MaskViewModel
    
    @State private var value: Float = 0.45
    
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
                            Text("8H")
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
                    ForEach(Mask.MaskType.allCases, id: \.self) { (maskType) in
                        PrimaryButton(
                            action: { maskVM.createMask(of: maskType) },
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
