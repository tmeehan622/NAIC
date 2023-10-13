//
//  SettingsViewController.swift
//  NAIC Codes
//
//  Created by Tom Meehan on 1/9/19.
//  Copyright © 2019 Thomas Meehan. All rights reserved.
//

import UIKit
import MessageUI
import Flurry_iOS_SDK

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate   {
    @IBOutlet weak var AboutPanel: UIView!
    @IBOutlet weak var tblView: UITableView!
    var cellFont:UIFont = ConfigurationManager.shared.tableCellFont()
    var tableBGColor:UIColor = ConfigurationManager.shared.tableViewBackGroundColor()
    var tableSepColor:UIColor = ConfigurationManager.shared.tableSeparatorColor()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
   }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
       Flurry.logEvent("Settings Page Opened", withParameters: nil);
    }
    
    @IBAction func AboutAction(_ sender: UIButton) {
        performSegue(withIdentifier: "flipper3", sender: sender)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingscell", for: indexPath)
        cell.textLabel!.text = settingsItems[indexPath.row]
        cell.textLabel!.font = cellFont
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "terms" {
            let destController = segue.destination as? TermsViewController
            destController?.context = 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 0 {
            presentEmailUI()
        }
        if indexPath.row == 1 {
            performSegue(withIdentifier: "flipper3", sender: self)
        }
        if indexPath.row == 2 {
            performSegue(withIdentifier: "disclaimer", sender: self)
        }
        if indexPath.row == 3 {
            performSegue(withIdentifier: "terms", sender: self)
        }
        if indexPath.row == 4 {
            performSegue(withIdentifier: "dirlist", sender: self)
        }
    }
    
    func presentEmailUI(){
        
        if MFMailComposeViewController.canSendMail() {
            let bodyText = "<html><head></head><body><p>NAIC Codes is now available in the App Store.</p></body></html>"
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setMessageBody(bodyText, isHTML: true)
            mailComposeViewController.setSubject("Please review the NAIC codes iPhone App")
            mailComposeViewController.setBccRecipients(["info@visualsoftinc.com"])
            
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let mailalert = UIAlertController(title: nil, message: "There appears to be no email account setup on this device.  Unable to send email", preferredStyle: .alert)
            
            let okaction = UIAlertAction(title: "Ok", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            mailalert.addAction(okaction)
            
            self.present(mailalert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            //print("User cancelled")
            break
        case .saved:
            //print("Mail is saved by user")
            break
        case .sent:
            //print("Mail is sent successfully")
            break
        case .failed:
            //print("Sending mail is failed")
            break
        default:
            break
        }
        
        controller.dismiss(animated: true)
    }
}



