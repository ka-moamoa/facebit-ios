//
//  RespiratoryClsWidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/11/21.
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

struct RespiratoryClsWidgetView: View {
    @ObservedObject private var publisher: RespitoryClassifierViewModel
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(timeOffset: TimeInterval=5, timerInterval: TimeInterval = 25) {
        self.publisher = RespitoryClassifierViewModel(
            appDatabase: AppDatabase.shared,
            timeOffset: timeOffset
        )
    }
    
    var body: some View {
        WidgetView {
            VStack {
                Text("Resp. Class.")
                    .bold()
                Spacer()
                Text(publisher.classification.label)
                    .font(.system(size: 32.0))
                Spacer()
            }
        }
    }
}

struct RespiratoryClsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        RespiratoryClsWidgetView()
    }
}
