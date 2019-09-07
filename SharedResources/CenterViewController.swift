//
//  CenterViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 01/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

@IBDesignable class CenterViewController: UIViewController {
    
    // MARK - Lifecycle
    
    @IBInspectable var displayMenuButton: Bool = true
    @IBInspectable var displayOptionsButton: Bool = true

    var rightButton: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if displayOptionsButton {
            // Set the right bar button item.
            
            rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            rightButton?.addTarget(self.navigationController, action: Selector(("optionsButtonTapped:")), for: UIControl.Event.touchDown)
            rightButton?.setBackgroundImage(#imageLiteral(resourceName: "OptionsIcon"), for: .normal)
            let rightBarButton = UIBarButtonItem(customView: rightButton!)
            rightBarButton.style = UIBarButtonItem.Style.plain
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
    }
}
