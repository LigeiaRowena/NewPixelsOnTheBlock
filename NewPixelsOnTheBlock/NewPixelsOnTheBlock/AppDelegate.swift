//
//  AppDelegate.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 29/08/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let homeViewController = HomeRouter.createViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

