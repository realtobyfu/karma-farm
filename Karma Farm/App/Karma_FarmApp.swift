//
//  Karma_FarmApp.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Firebase
import IQKeyboardManagerSwift
import Foundation
import SwiftUI

@main
struct KarmaFarmApp: App {
    init() {
        FirebaseApp.configure()
        IQKeyboardManager.shared.isEnabled = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthManager.shared)
                .environmentObject(LocationManager.shared)
        }
    }
}
