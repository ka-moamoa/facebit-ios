//
//  PurgeDatabaseButtonView().swift
//  FaceBit Companion
//
//  Created by blaine on 1/29/21.
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

struct PurgeDatabaseButtonView: View {
    @State private var showConfirmationAlert: Bool = false
    
    var body: some View {
        Button(action: {
            showConfirmationAlert = true
        }, label: {
            Text("🚨 Purge Database")
                .padding()
        })
        .alert(isPresented: $showConfirmationAlert, content: {
            Alert(
                title: Text("Purge Local Database"),
                message: Text("All facebit data will be delted from this device, this cannot be undone. To save a copy, first share the database file."),
                primaryButton: .destructive(Text("Delete"), action: purge),
                secondaryButton: .cancel(Text("Cancel"))
            )
        })
    }
    
    // FIXME: move to viewmodel
    private func purge() {
        showConfirmationAlert = false
        do {
            try AppDatabase.shared.purge()
        } catch {
            PersistanceLogger.error("Unable to purge database: \(error.localizedDescription)")
        }
    }
}

struct PurgeDatabaseButtonView___Previews: PreviewProvider {
    static var previews: some View {
        PurgeDatabaseButtonView()
    }
}
