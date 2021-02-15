//
//  ProgressBar.swift
//  FaceBit Companion
//
//  Created by blaine on 2/14/21.
//

// Credit: https://www.simpleswiftguide.com/how-to-build-linear-progress-bar-in-swiftui/

import SwiftUI

struct ProgressBar: View {
    @State var value: Float
    
    @State var backgroundColor = Color("PrimaryBrown")
    @State var progressColor = Color("PrimaryMint")
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(backgroundColor)
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(progressColor)
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    
    static var previews: some View {
        ProgressBar(value: 0.5)
    }
}
