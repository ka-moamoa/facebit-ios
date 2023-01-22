//
//  Color+Extension.swift
//  FaceBit Companion
//
//  Created by Andreas Ink on 1/22/23.
//

import SwiftUI

// Easier references to Color for use in SwiftUI
extension Color {
    static let primaryBrown = Color("PrimaryBrown")
    static let primaryMint = Color("primaryMint")
    static let primaryOrange = Color("PrimaryOrange")
    static let primaryPurple = Color("PrimaryPurple")
    static let primaryWhite = Color("PrimaryWhite")
    
    // Array of colors for styling charts and other views
    static let primaries: [Color] = [.primaryMint, .primaryBrown, .primaryOrange, .primaryPurple, .primaryMint.opacity(0.4), .primaryPurple.opacity(0.4), .primaryBrown.opacity(0.4)]
}
