//
//  SET10101App.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI
import Firebase

@main
struct SET10101App: App
{
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init()
    {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.debug)
    }
    
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
        }
    }
}
