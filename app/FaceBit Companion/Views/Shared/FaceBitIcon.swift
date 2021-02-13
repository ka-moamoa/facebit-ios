//
//  FacebitIcon.swift
//  FaceBit Companion
//
//  Created by blaine on 2/12/21.
//

import SwiftUI

struct FaceBitIcon: View {
    var body: some View {
        Image("face-mask")
            .resizable()
            .padding(10.0)
            .scaledToFit()
            .background(
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color("PrimaryMint"))
                    .foregroundColor(Color("PrimaryMint"))
            )
    }
}

struct FacebitIcon_Previews: PreviewProvider {
    static var previews: some View {
        FaceBitIcon()
    }
}
