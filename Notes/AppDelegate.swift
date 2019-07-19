//
//  AppDelegate.swift
//  Notes
//
//  Created by Миландр on 24/06/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        prepareLogger()
        DDLogInfo("\(type(of: self)): \(#function)")
        
        FileNotebook.shared.loadFromFile()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DDLogInfo("\(type(of: self)): \(#function)")
        FileNotebook.shared.saveToFile()
    }
    
    private func prepareLogger() {
        DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }

}

