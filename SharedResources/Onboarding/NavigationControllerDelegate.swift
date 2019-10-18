//
//  NavigationControllerDelegate.swift
//  CircleTransition
//
//  Created by Rounak Jain on 23/10/14.
//  Copyright (c) 2014 Rounak Jain. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    @IBOutlet weak var navigationController: UINavigationController?
  
    var shouldComplete: Bool = false
    var interactionController: UIPercentDrivenInteractiveTransition?
    var initialDirectionIsRight = false
    
    var interactionDisabled: Bool = false

    #if targetEnvironment(macCatalyst)
    var rightButton:UIButton!
    var leftButton:UIButton!
    #endif


    
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let navigationController = self.navigationController else {
            return
        }

        #if targetEnvironment(macCatalyst)

        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .light, scale: .large)
        self.rightButton = UIButton(type: .system)
        self.rightButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: configuration), for: .normal)
        self.rightButton.tintColor = .label
        self.rightButton.sizeToFit()
        self.rightButton.translatesAutoresizingMaskIntoConstraints = false
        self.rightButton.addTarget(self, action: #selector(rightKeyPressed), for: .touchUpInside)

        self.leftButton = UIButton(type: .system)
        self.leftButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: configuration), for: .normal)
        self.leftButton.tintColor = .label
        self.leftButton.sizeToFit()
        self.leftButton.translatesAutoresizingMaskIntoConstraints = false
        self.leftButton.addTarget(self, action: #selector(leftKeyPressed), for: .touchUpInside)

        navigationController.view.addSubview(self.rightButton)
        navigationController.view.addSubview(self.leftButton)

        //right button constraints
        navigationController.view.addConstraints([

            NSLayoutConstraint(item: self.rightButton!, attribute: .centerY, relatedBy: .equal, toItem: navigationController.view, attribute: .centerY, multiplier: 1, constant: -100),
            NSLayoutConstraint(item: self.rightButton!, attribute: .trailing, relatedBy: .equal, toItem: navigationController.view, attribute: .trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: self.rightButton!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100),
             NSLayoutConstraint(item: self.rightButton!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)

        ])

        //left button constraints
        navigationController.view.addConstraints([

            NSLayoutConstraint(item: self.leftButton!, attribute: .centerY, relatedBy: .equal, toItem: navigationController.view, attribute: .centerY, multiplier: 1, constant: -100),
            NSLayoutConstraint(item: self.leftButton!, attribute: .leading, relatedBy: .equal, toItem: navigationController.view, attribute: .leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: self.leftButton!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100),
             NSLayoutConstraint(item: self.leftButton!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)

        ])

        self.leftButton.isHidden = true
        self.leftButton.alpha = 0
        #else
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(NavigationControllerDelegate.panned(_:)))
        navigationController.view.addGestureRecognizer(panGesture)
        #endif
    }

    func animateButton(button: UIButton, show: Bool) {
        DispatchQueue.main.async {
            if show {
                button.isHidden = false
                UIView.animate(withDuration: 0.4, animations: {
                    button.alpha = 1
                })
            } else {
                UIView.animate(withDuration: 0.4, animations: {
                    button.alpha = 0
                }) { (completed) in
                    button.isHidden = true
                }
            }
        }
    }

    @objc func rightKeyPressed() {
        if self.navigationController?.topViewController!.isKind(of: TestTriggertViewController.self) != true {
            self.interactionController = UIPercentDrivenInteractiveTransition()
            self.navigationController?.topViewController!.performSegue(withIdentifier: "PushSegue", sender: nil)
        }
        if let interactionController = self.interactionController {
            interactionController.finish()
            interactionDisabled = true

            self.interactionController = nil
        }

        #if targetEnvironment(macCatalyst)
        self.animateButton(button: self.leftButton, show: !(self.navigationController?.topViewController!.isKind(of: KitSelectorViewController.self))!)
        self.animateButton(button: self.rightButton, show: !(self.navigationController?.topViewController!.isKind(of: TestTriggertViewController.self))!)
        #endif
    }

    @objc func leftKeyPressed() {
        if self.navigationController?.topViewController!.isKind(of: KitSelectorViewController.self) != true && self.navigationController?.topViewController!.isKind(of: CameraSelectorViewController.self) != true && self.navigationController?.topViewController!.isKind(of: SplashViewController.self) != true {
            
            self.interactionController = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewController(animated: true)
        }

        if let interactionController = self.interactionController {
            interactionController.finish()
            interactionDisabled = true

            self.interactionController = nil
        }
        
        #if targetEnvironment(macCatalyst)
        self.animateButton(button: self.leftButton, show: !(self.navigationController?.topViewController!.isKind(of: KitSelectorViewController.self))!)
        self.animateButton(button: self.rightButton, show: !(self.navigationController?.topViewController!.isKind(of: TestTriggertViewController.self))!)
        #endif
    }
  
    @IBAction func panned(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        if interactionDisabled {
            print("Interaction Disabled - Animation is still in process", terminator: "")
            return
        }
        
        let velocity = gestureRecognizer.velocity(in: self.navigationController!.view)
        let rightDirection = velocity.x < 0 ? true : false
        
        switch gestureRecognizer.state {
            case .began:
            initialDirectionIsRight = rightDirection
            
            if !rightDirection && self.navigationController?.topViewController!.isKind(of: KitSelectorViewController.self) != true && self.navigationController?.topViewController!.isKind(of: CameraSelectorViewController.self) != true && self.navigationController?.topViewController!.isKind(of: SplashViewController.self) != true {
                self.interactionController = UIPercentDrivenInteractiveTransition()
                self.navigationController?.popViewController(animated: true)
            } else if rightDirection && self.navigationController?.topViewController!.isKind(of: TestTriggertViewController.self) != true  {
                self.interactionController = UIPercentDrivenInteractiveTransition()
                self.navigationController?.topViewController!.performSegue(withIdentifier: "PushSegue", sender: nil)
            }
                
            case .changed:
                
                if let interactionController = self.interactionController {
                    
                    let translation = gestureRecognizer.translation(in: self.navigationController!.view)
                    
                    let dragAmount: CGFloat = self.navigationController!.view.frame.width / 2
                    let threshold: CGFloat = 0.5
                    
                    var percent = translation.x / dragAmount
                    var multiplier: CGFloat = 1.0
                    
                    // User's initial swipe is the same direction as the current one
                    if initialDirectionIsRight == rightDirection {
                        
                        multiplier = translation.x < 0 ? -1.0 : 1.0
                    // User changed the direction of swiping
                    } else {
                        if translation.x < 0 && !rightDirection {
                            multiplier = -1.0
                        } else if translation.x > 0 && rightDirection {
                            multiplier = 1.0
                        } else {
                            multiplier = 0
                        }
                    }

                    percent *= multiplier
                    percent = fmax(percent, 0.0)
                    percent = fmin(percent, 0.99) 
                    
                    interactionController.update(percent)
                    shouldComplete = percent >= threshold
                }
                
            case .ended:
                if let interactionController = self.interactionController {
                    if shouldComplete == false {
                        interactionController.cancel()
                        interactionDisabled = false
                    } else {
                        interactionController.finish()
                        interactionDisabled = true
                    }
                    
                    self.interactionController = nil
                }
                
            default:
                if let interactionController = self.interactionController {
                    interactionController.cancel()
                    self.interactionController  = nil
                    interactionDisabled = false
                }
            }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) { 
        interactionDisabled = false
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("From VC: \(fromVC) To VC: \(toVC)", terminator: "")
        
        // Stage 1 transitions
        if fromVC.isKind(of: KitSelectorViewController.self) && toVC.isKind(of: CameraSelectorViewController.self) {
            
            print("KitToCameraSelectorTransition", terminator: "")
            return KitToCameraSelectorTransition()
            
        } else if fromVC.isKind(of: KitSelectorViewController.self) && toVC.isKind(of: ConnectKitViewController.self) {
            print("KitToConnectTransition Push", terminator: "")
            
            let transition = KitToConnectTransition()
            transition.state = KitToConnectTransition.State.push
            return transition
            
        } else if fromVC.isKind(of: ConnectKitViewController.self) && toVC.isKind(of: KitSelectorViewController.self) {
            
            print("KitToConnectTransition Pop", terminator: "")
            let transition = KitToConnectTransition()
            transition.state = KitToConnectTransition.State.pop
            return transition
            
        } else if fromVC.isKind(of: CameraSelectorViewController.self) && toVC.isKind(of: ConnectKitViewController.self) {
            
            print("CameraSelectorToConnectTransition Push", terminator: "")
            let transition = CameraSelectorToConnectTransition()
            transition.state = CameraSelectorToConnectTransition.State.push
            return transition
            
        } else if fromVC.isKind(of: ConnectKitViewController.self) && toVC.isKind(of: CameraSelectorViewController.self) {
            
            print("CameraSelectorToConnectTransition Pop", terminator: "")
            let transition = CameraSelectorToConnectTransition()
            transition.state = CameraSelectorToConnectTransition.State.pop
            return transition
            
        } else if fromVC.isKind(of: ConnectKitViewController.self) && toVC.isKind(of: VolumeViewController.self) {
            
            print("ConnectToVolumeTransition Push", terminator: "")
            let transition = ConnectToVolumeTransition()
            transition.state = ConnectToVolumeTransition.State.push
            return transition
            
        } else if fromVC.isKind(of: VolumeViewController.self) && toVC.isKind(of: ConnectKitViewController.self) {
            
            print("ConnectToVolumeTransition Pop", terminator: "")
            let transition = ConnectToVolumeTransition()
            transition.state = ConnectToVolumeTransition.State.pop
            return transition
            
        } else if fromVC.isKind(of: VolumeViewController.self) && toVC.isKind(of: CameraViewController.self) {
            
            print("VolumeToCameraTransition Push", terminator: "")
            let transition = VolumeToCameraTransition()
            transition.state = VolumeToCameraTransition.State.push
            return transition
            
        } else if fromVC.isKind(of: CameraViewController.self) && toVC.isKind(of: VolumeViewController.self) {
            
            print("VolumeToCameraTransition Pop", terminator: "")
            let transition = VolumeToCameraTransition()
            transition.state = VolumeToCameraTransition.State.pop
            return transition
            
        } else if fromVC.isKind(of: CameraViewController.self) && toVC.isKind(of: ManualFocusViewController.self) {
            
            print("CameraToManualFocusTransition Push", terminator: "")
            let transition = CameraToManualFocusTransition()
            transition.state = CameraToManualFocusTransition.State.push
            return transition
            
        }  else if fromVC.isKind(of: ManualFocusViewController.self) && toVC.isKind(of: CameraViewController.self) {
            
            print("CameraToManualFocusTransition Pop", terminator: "")
            let transition = CameraToManualFocusTransition()
            transition.state = CameraToManualFocusTransition.State.pop
            return transition
            
        } else if fromVC.isKind(of: ManualFocusViewController.self) && toVC.isKind(of: TestTriggertViewController.self) {
            
            print("ManualFocusToTestTriggerTransition Push", terminator: "")
            let transition = ManualFocusToTestTriggerTransition()
            transition.state = ManualFocusToTestTriggerTransition.State.push
            return transition
            
        } else if fromVC.isKind(of: TestTriggertViewController.self) && toVC.isKind(of: ManualFocusViewController.self) {
            
            print("ManualFocusToTestTriggerTransition Pop", terminator: "")
            let transition = ManualFocusToTestTriggerTransition()
            transition.state = ManualFocusToTestTriggerTransition.State.pop
            return transition
            
        } else if fromVC.isKind(of: SplashViewController.self) && toVC.isKind(of: KitSelectorViewController.self) {
            
            // Use custom transition here if needed between the splash view controller and the kit selector view controller
            
            return nil
        }
        
        print("Nil", terminator: "")
        return nil
    }
  
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
}
