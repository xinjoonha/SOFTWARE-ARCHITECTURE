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
        FirebaseConfiguration.shared.setLoggerLevel(.error)
    }
    
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
        }
    }
}
