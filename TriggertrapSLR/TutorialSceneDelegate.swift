//
//  TutorialSceneDelegate.swift
//  TriggertrapSLR
//
//  Created by Alex Taffe on 9/17/19.
//  Copyright © 2019 Triggertrap Limited. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class TutorialSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else {
            return
        }

        let onboardingStoryboard = UIStoryboard(name: constStoryboardIdentifierOnboarding, bundle: Bundle.main)

        var viewControllerIdentifier: String?

        if (UserDefaults.standard.object(forKey: constSplashScreenIdentifier) != nil) {
            viewControllerIdentifier = constMobileKitIdentifier
        } else {
            viewControllerIdentifier = constSplashScreenIdentifier
            UserDefaults.standard.set(true, forKey: constSplashScreenIdentifier)
            UserDefaults.standard.synchronize()
        }

        // Make sure that the identifier is not nil (in case it gets changed by mistake)
        if let viewControllerIdentifier = viewControllerIdentifier {

            let viewController = onboardingStoryboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
            let navController = onboardingStoryboard.instantiateInitialViewController() as! UINavigationController

            navController.viewControllers = [viewController]

//            navController.modalPresentationStyle = UIModalPresentationStyle.formSheet
//
//            let detailNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailNavController") as! DetailNavigationController
//            detailNavigationController.pushViewController(settingsController, animated: false)

            window?.rootViewController = navController
        } else {
            print("Warning: View Controller Identifier is nil. Cannot show onboarding")
        }




        //settingsController.navigationItem.backBarButtonItem = nil

        #if targetEnvironment(macCatalyst)
            if let windowScene = scene as? UIWindowScene {
                windowScene.title = "Settings"
                if let titlebar = windowScene.titlebar {
                    titlebar.titleVisibility = .hidden

                }
            }
        #endif
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        //(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}


