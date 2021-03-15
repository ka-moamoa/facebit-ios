//
//  PurgeDatabaseButtonView().swift
//  FaceBit Companion
//
//  Created by blaine on 1/29/21.
//

import SwiftUI

struct PurgeDatabaseButtonView: View {
    var body: some View {
        Button(action: {
            purge()
        }, label: {
            Text("Purge Database")
                .padding()
        })
    }
    
    // FIXME: move to viewmodel
    private func purge() {
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
