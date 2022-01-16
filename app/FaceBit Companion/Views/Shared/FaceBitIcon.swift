//
//  FacebitIcon.swift
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

struct FaceBitIcon: View {
    var body: some View {
        Image("face-mask_3")
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
