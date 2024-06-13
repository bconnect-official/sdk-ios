//
//  AppDelegate.swift
//  BConnect
//

import UIKit
import BConnect

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("\n# AppDelegate didFinishLaunchingWithOptions")
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("\n# AppDelegate open url: \(url.absoluteString)")
        
        if BConnect.shared.application(open: url) {
            return true
        }

        return false
    }
}
