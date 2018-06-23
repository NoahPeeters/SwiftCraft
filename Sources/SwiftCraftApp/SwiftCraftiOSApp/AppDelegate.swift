//
//  AppDelegate.swift
//  SwiftCraftiOSApp
//
//  Created by Noah Peeters on 23.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import UIKit

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}

extension UIViewController {
    public func presentAlert(title: String, message: String, handler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            handler?()
        })
        present(alert, animated: true, completion: nil)
    }
}
