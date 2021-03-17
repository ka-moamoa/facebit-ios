//
//  PurgeDatabaseButtonView().swift
//  FaceBit Companion
//
//  Created by blaine on 1/29/21.
//

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
