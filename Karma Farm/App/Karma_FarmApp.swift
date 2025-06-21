//
//  Karma_FarmApp.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift
import Foundation
import SwiftUI
import UserNotifications

@main
struct KarmaFarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("🔥 AppDelegate: Starting Firebase configuration")
        
        // Configure Firebase
        do {
            FirebaseApp.configure()
            print("🔥 AppDelegate: Firebase configured successfully")
//            // Disable app verification for testing on simulator
//            #if targetEnvironment(simulator)
//            Auth.auth().settings?.isAppVerificationDisabledForTesting = true
//            print("🔥 AppDelegate: Disabled app verification for testing")
//            #endif
            
            // Verify Firebase app is available
            if let app = FirebaseApp.app() {
                print("🔥 AppDelegate: Firebase app name: \(app.name)")
                print("🔥 AppDelegate: Firebase app options: \(app.options)")
            } else {
                print("🔥 ERROR: Firebase app is nil after configuration!")
            }
        } catch {
            print("🔥 ERROR: Firebase configuration failed: \(error)")
        }
        
        // Set up APNs for phone authentication
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("🔥 AppDelegate: Notification permission granted: \(granted)")
            if let error = error {
                print("🔥 AppDelegate: Notification permission error: \(error)")
            }
        }
        application.registerForRemoteNotifications()
        
        // Set Auth language to match device
        Auth.auth().languageCode = nil
        print("🔥 AppDelegate: Auth language set to device default")
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        // Handle other remote notifications
        completionHandler(.noData)
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
}
