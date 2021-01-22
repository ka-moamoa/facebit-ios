//
//  MetricDashboardView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import Foundation
import SwiftUI

protocol MetricDashboardView: View {
    var facebit: FaceBitPeripheral { get }
}
