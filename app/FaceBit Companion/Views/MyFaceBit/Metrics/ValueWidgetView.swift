//
//  ValueWidgetView.swift
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

struct ValueWidgetView: View {
    @State var title: String
    @State var unit: String
    @Binding var value: Double
    
    var body: some View {
        WidgetView {
            VStack {
                Text(title)
                    .bold()
                Text("\(String(format: "%.2f", value))")
                    .font(.system(size: 48.0))
                Text(unit)
            }
        }
    }
}

struct ValueWidgetView_Previews: PreviewProvider {
    @State static var value: Double = 123.04
    
    static var previews: some View {
        ValueWidgetView(title: "Metric", unit: "coins", value: $value)
    }
}
