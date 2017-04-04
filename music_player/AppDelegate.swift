//
//  AppDelegate.swift
//  music_player
//
//  Created by yulz on 3/28/17.
//  Copyright © 2017 yulz. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Enable Background
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)
        try! session.setActive(true)
        
        return true
    }
}

