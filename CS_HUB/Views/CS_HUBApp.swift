//
//  CS_HUBApp.swift
//  CS_HUB
//
//  Created by Nikstanov on 13.03.24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate{
    internal func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
        FirebaseApp.configure()
        return true
    }
}

@main
struct CS_HUBApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var dataManager = APIManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                if Auth.auth().currentUser != nil{
                    ContentView()
                }
                else{
                    AuthFormView()
                }
            }
            .environmentObject(dataManager)
        }
    }
}
