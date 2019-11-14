//
//  LeftPanelTableViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 01/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class LeftPanelViewController: UITableViewController {
    
    // Cable Release modes
    
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    fileprivate var modes: NSArray?
    
    // MARK - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.separatorColor = UIColor.clear
        
        tableView.register(UINib(nibName: "ModeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ModeTableViewCell")

        #if targetEnvironment(macCatalyst)
        modes = NSArray(contentsOfFile: pathForResource("Modes Mac"))
        #else
        modes = NSArray(contentsOfFile: pathForResource("Modes"))
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(LeftPanelViewController.removeActiveCell(_:)), name: NSNotification.Name(rawValue: "DidRemoveActiveViewController"), object: nil)

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 125, height: 30.729166666667))
        imageView.image = UIImage(named: "TriggertrapLogo")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.triggertrap_iconColor()

        let imageViewContainer = UIImageView(frame: CGRect(x: 0, y: 0, width: 125, height: 30.729166666667))
        imageViewContainer.tintColor = UIColor.triggertrap_iconColor()
        imageViewContainer.addSubview(imageView)

        self.navigationItem.titleView = imageViewContainer

        NotificationCenter.default.addObserver(self, selector: #selector(wifiChanged), name: Notification.Name(rawValue: constWatchDidTrigger), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        self.view.backgroundColor = UIColor.triggertrap_fillColor()
        self.tableView.backgroundColor = UIColor.triggertrap_backgroundColor(1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
    }

    
    // MARK: - Notifications
    
    @objc func removeActiveCell(_ sender: Notification) {
        self.tableView.reloadData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *){
            self.tableView.reloadData()
            self.view.backgroundColor = UIColor.triggertrap_fillColor()
            self.tableView.backgroundColor = UIColor.triggertrap_backgroundColor(1.0)
            self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        }
        
    }

    @objc func wifiChanged() {
        self.tableView.reloadData()
    }
}

//MARK: Datasource

extension LeftPanelViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return modes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((modes?[section] as AnyObject).object(at: 1) as! NSArray).count 
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModeTableViewCell", for: indexPath) as! ModeTableViewCell
        
        if let modes = modes, let modesSection = (modes[indexPath.section] as? NSArray), let modesInSection = modesSection[1] as? NSArray, let mode = modesInSection[indexPath.row] as? NSDictionary {
            
            cell.titleLabel.text = NSLocalizedString(mode["title"] as! String, tableName: "ModesPlist", bundle: Bundle.main, value: "Title", comment: "Ignore when translating")
            
            cell.titleLabel.textColor = UIColor.triggertrap_accentColor()
            cell.identifier = mode["identifier"] as? String
            cell.backgroundColor = UIColor.triggertrap_fillColor()
            cell.icon.image = ImageWithColor(UIImage(named: mode["icon"] as! String)!, color: UIColor.triggertrap_iconColor())
            cell.remoteSupported = mode["remoteSupported"] as! Bool
            cell.wearablesSupported = mode["wearablesSupported"] as! Bool
            cell.usesSmartColor = false
            cell.backgroundFadeColor = UIColor.triggertrap_fillColor()
            
            if WearablesManager.sharedInstance.isWearablesModeRunning() && !cell.wearablesSupported {
                cell.descriptionLabel.text = NSLocalizedString("Not available with Wearable mode running", comment: "Not available with Wearable mode running")
                cell.square.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_naturalColor(), change: CGFloat(indexPath.row) * 0.1)
                cell.isUserInteractionEnabled = false
            } else if WifiDispatcher.sharedInstance.remoteOutputServer.delegate != nil && !cell.remoteSupported  {
                cell.descriptionLabel.text = NSLocalizedString("Not available with Wifi Master running", comment: "Not available with Wifi Master running")
                cell.square.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_naturalColor(), change: CGFloat(indexPath.row) * 0.1)
                cell.isUserInteractionEnabled = false
            } else {
                cell.descriptionLabel.text = NSLocalizedString(mode["description"] as! String, tableName: "ModesPlist", bundle: Bundle.main, value: "Description", comment: "Ignore when translating")
                cell.square.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_primaryColor(), change: CGFloat(indexPath.row) * 0.1)
                cell.isUserInteractionEnabled = true
            }
            
            cell.descriptionLabel.textColor = UIColor.triggertrap_foregroundColor()
            cell.separatorView.backgroundColor = UIColor.triggertrap_clearColor()
            
            if let activeViewController = SequenceManager.sharedInstance.activeViewController, cell.identifier == activeViewController.restorationIdentifier {
                cell.activityIndicator.startAnimating()
            } else {
                cell.activityIndicator.stopAnimating()
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 22.0))
        sectionBackgroundView.backgroundColor = UIColor.triggertrap_backgroundColor(1.0)
        
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: self.tableView.frame.width, height: 22.0))
        
        label.text = NSLocalizedString((modes?[section] as AnyObject).object(at: 0) as! String, tableName: "ModesPlist", bundle: Bundle.main, value: "Section", comment: "Ignore when translating")
        label.font = UIFont.triggertrap_metric_regular(18.0)
        label.textColor = UIColor.triggertrap_accentColor(1.0)
        
        sectionBackgroundView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                label.leftAnchor.constraint(equalTo: sectionBackgroundView.safeAreaLayoutGuide.leftAnchor, constant: 5.0)
            ])
        }
        
        
        return sectionBackgroundView
    } 
}

//MARK: Table Delegate

extension LeftPanelViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ModeTableViewCell
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .systemGray5
        } else {
            cell.backgroundColor = UIColor(red: 229 / 255, green: 229 / 255, blue: 234 / 255, alpha: 1)
        }
        
        guard let identifier = cell.identifier else {
            return
        }
        
        if WifiDispatcher.sharedInstance.remoteOutputServer.delegate != nil {
            
            if cell.remoteSupported {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SidebarDidSelectCellWithIdentifier"), object:identifier)
            }
        } else if WearablesManager.sharedInstance.isWearablesModeRunning() {
            if cell.wearablesSupported {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SidebarDidSelectCellWithIdentifier"), object:identifier)
            }
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SidebarDidSelectCellWithIdentifier"), object:identifier)
        }
         
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ModeTableViewCell else {
            return
        }
        if #available(iOS 13.0, *) {
            cell.backgroundColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return .white
                } else {
                    return .black
                }
            }
        } else {
            cell.backgroundColor = .white
        }
    }
}
