//
//  KeyValueRow.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct KeyValueRow: View {
    @State var key: String
    @State var value: String
    
    var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
            foregroundColor(.gray)
        }
    }
}

struct KeyValueRow_Previews: PreviewProvider {
    static var previews: some View {
        KeyValueRow(key: "App Version", value: "0.1.0")
    }
}
