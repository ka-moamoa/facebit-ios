//
//  ShareDatabaseButtonView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/28/21.
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

struct ShareDatabaseButtonView: View {
    
    var text: String {
        #if targetEnvironment(macCatalyst)
        return "Open Local Database"
        #else
        return "Share Local Database"
        #endif
    }
    
    var body: some View {
        Button(action: {
            shareDatabase()
        }, label: {
            Text(text)
                .padding()
        })
    }
    
    private func shareDatabase() {
        #if targetEnvironment(macCatalyst)
            print("macOS")
            if let dbPath = AppDatabase.dbPath {
                UIApplication.shared.open(dbPath)
            }
            
        #elseif os(iOS) || os(watchOS) || os(tvOS)
            print("iOS")
            if let dbPath = AppDatabase.dbPath {
                let av = UIActivityViewController(
                    activityItems: [dbPath],
                    applicationActivities: nil
                )
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
            }
        #else
            // unknown os
        #endif
    }
}

struct ShareDatabaseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ShareDatabaseButtonView()
    }
}
