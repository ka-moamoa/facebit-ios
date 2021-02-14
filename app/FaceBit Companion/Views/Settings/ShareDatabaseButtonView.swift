//
//  ShareDatabaseButtonView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/28/21.
//

import SwiftUI

struct ShareDatabaseButtonView: View {
    
    var text: String {
        #if targetEnvironment(macCatalyst)
        return "Open SQLite Database"
        #else
        return "Share SQLite Database"
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
            UIApplication.shared.open(SQLiteDatabase.dbPath)
        #elseif os(iOS) || os(watchOS) || os(tvOS)
            print("iOS")
            guard let data = SQLiteDatabase.dbPath else { return }
            let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
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
