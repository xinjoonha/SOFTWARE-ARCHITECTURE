//
//  AppDelegate.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
            FirebaseApp.configure()
            return true
    }

}
