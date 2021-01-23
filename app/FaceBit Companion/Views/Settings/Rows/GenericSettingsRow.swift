//
//  GenericSettingsRow.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct GenericSettingsRow: View {
    @State var text: String
    
    var body: some View {
        HStack {
            Text(text)
        }
        .padding()
    }
}

struct GenericSettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        GenericSettingsRow(text: "Record Events")
    }
}
