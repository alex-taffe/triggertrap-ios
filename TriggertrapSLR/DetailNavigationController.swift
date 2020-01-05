//
//  DetailNavigationController.swift
//  Triggertrap
//
//  Created by Alex Taffe on 9/7/19.
//  Copyright © 2019 Triggertrap Limited. All rights reserved.
//

import UIKit

class DetailNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return AppTheme() == .normal ? .lightContent : .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBar.isTranslucent = false

    }

    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 13.0, *){
            self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemBackground]
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        }

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *){
            self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemBackground]
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


    // MARK: - Actions

    @objc func optionsButtonTapped(_ sender: UIBarButtonItem) {

        // Inform the active view controller that it will loose focus - Quick Release and Press and Hold modes
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ActiveViewControllerLostFocus"), object: nil)

        let storyboard = UIStoryboard(name: ConstStoryboardIdentifierOptions, bundle: Bundle.main)
        let viewController = storyboard.instantiateInitialViewController()!

        let destinationController = storyboard.instantiateViewController(withIdentifier: "optionsController")

        // Present the options view controller in full screen
        if #available(iOS 13.0, *) {
            viewController.modalPresentationStyle = .automatic
        } else {
            viewController.modalPresentationStyle = .fullScreen
        }
        viewController.modalPresentationCapturesStatusBarAppearance = true

        destinationController.modalPresentationCapturesStatusBarAppearance = true

        self.present(viewController, animated: true, completion: nil)


    } 
}
