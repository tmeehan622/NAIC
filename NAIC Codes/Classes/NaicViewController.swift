//
//  NaicViewController.swift
//  NAIC Codes
//
//  Created by Tom Meehan on 1/9/19.
//  Copyright © 2019 Thomas Meehan. All rights reserved.
//

import UIKit
import MessageUI
import Flurry_iOS_SDK

class NaicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var AboutPanel: UIView!
    @IBOutlet weak var headerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var spacerItem: UIBarButtonItem!
    @IBOutlet weak var leftSpacerItem: UIBarButtonItem!
    @IBOutlet weak var emailBBItem: UIBarButtonItem!
    @IBOutlet weak var favoritesBBItem: UIBarButtonItem!
    @IBOutlet weak var rightSpacer: UIBarButtonItem!
    @IBOutlet weak var hiddenEmailLabel: UILabel!
    @IBOutlet weak var hiddenFavoritesLabel: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    var cellFont:UIFont = ConfigurationManager.shared.tableCellFont()
    var tableBGColor:UIColor = ConfigurationManager.shared.tableViewBackGroundColor()
    var tableSepColor:UIColor = ConfigurationManager.shared.tableSeparatorColor()
    var rawData:Dictionary<String, AnyObject>?
    var masterList:Array<AnyObject>?
    let appDelegate     = UIApplication.shared.delegate as! AppDelegate
    let barMargin:CGFloat = 0.0
    var navTitle:String = ""
    var headerText:String = ""
    var disableFarvoritesButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustToolbarItems()
        tblView.backgroundColor = tableBGColor
        tblView.separatorColor = tableSepColor
        
          NotificationCenter.default.addObserver(self, selector: #selector(handleBookMarkAdded(notification:)), name: Notification.Name.bookMarkAdded, object: nil)
   
        if headerText.count > 0 {
            headerLabel.text = headerText
        }
        if navTitle.count > 0 {
            navigationItem.title = navTitle
        } else {
            navigationItem.title = "NAIC Codes"
        }
        
        if rawData == nil {
          rawData = appDelegate.rawData
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        let navtitle = navigationController?.title
        
        disableFarvoritesButton = navtitle == "Favorite Navigation"
        let keys = Array((rawData?.keys)!)
        let sortedKeys =  keys.sorted()
        let c = sortedKeys.count
        
        favoritesBBItem.isEnabled = !disableFarvoritesButton
        
        if dictHasKey(rawData!,"children") == false {
            favoritesBBItem.isEnabled = false
        }
        
        if masterList != nil {
            masterList?.removeAll()
        } else {
            masterList = []
        }
        
        if dictHasKey(rawData!,"children") {
            masterList = (rawData!["children"] as! Array<AnyObject>)
        } else {
            for indx in 0 ..< c{
                let k = sortedKeys[indx]
                let d = rawData?[k]
                masterList?.append(d!)
            }
        }
    }

    func showAlertMessage(_ alrtType:String){
        let mess = "Your bookmark was " + alrtType
            let favoritesAlert = UIAlertController(title: nil, message: mess, preferredStyle: .alert)
            
            let okaction = UIAlertAction(title: "Ok", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.tblView.reloadData()
            })
            
            favoritesAlert.addAction(okaction)
            self.present(favoritesAlert, animated: true, completion: nil)
    }
    
    func dictHasKey(_ dict:Dictionary<String, AnyObject>, _ key:String)->Bool{
        if let _ = dict[key] {
            return true
        }
        else {
            return false
        }
    }
    
    func adjustToolbarItems(){
        leftSpacerItem.width = barMargin
        rightSpacer.width = barMargin
        let padding:CGFloat = 15.0
        let fixedmargin:CGFloat = 15.0
        
        let scrWidth:CGFloat = screenWidth / scaleFactor
        let fWidth:CGFloat = hiddenFavoritesLabel.bounds.width
        let eWidth:CGFloat = hiddenEmailLabel.bounds.width
        let L1:CGFloat = hiddenFavoritesLabel.frame.maxX
        let L2:CGFloat = hiddenEmailLabel.frame.minX
        let M1:CGFloat = leftSpacerItem.width + fWidth + fixedmargin
        let M2:CGFloat = scrWidth - rightSpacer.width - eWidth - fixedmargin
        
        let calcWidth:CGFloat = (((scrWidth / 2.0) - M1) * 2.0) - padding
        headerWidthConstraint.constant = calcWidth
        if calcWidth > 580.0 {
            headerLabel.font = ConfigurationManager.shared.iPADHeaderFont()
        }
      }
   
    @IBAction func AboutAction(_ sender: UIButton) {
        performSegue(withIdentifier: "showabout", sender: sender)
    }

    @IBAction func favoritesAction(_ sender: UIBarButtonItem) {
        BookmarkManager.shared.addBookMark(bm:rawData!)
    }

    @IBAction func EAction(_ sender: UIBarButtonItem) {
        var pageText = ""
        
        let c1 = masterList?.count
        var c = 0
        
        if c1 != nil {
           c = c1!
        }
        
        for indx in 0 ..< c {
            let naicLBL = masterList![indx]["naicnum"] as! String
            let titleLBL = masterList![indx]["title"] as! String

            let linetext = naicLBL + "  " + titleLBL
            pageText = pageText + linetext + "\n"
        }
        presentEmailUI(pageText, navigationItem.title!)
     }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masterList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let reuseid = "naiccell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseid, for: indexPath)
        
        let naicLBL = cell.contentView.viewWithTag(10) as! UILabel
        let titleLBL = cell.contentView.viewWithTag(11) as! UILabel
        naicLBL.font = cellFont
        titleLBL.font = cellFont

        
        naicLBL.text = masterList![indexPath.row]["naicnum"] as! String
        titleLBL.text = masterList![indexPath.row]["title"] as! String
        
        let scrWidth:CGFloat = screenWidth / scaleFactor
        if scrWidth > 414.0 {
          var r = naicLBL.frame
          r.size.width = 200.0
          naicLBL.frame = r
        }
        
        if naicLBL.text!.count < 6 {
          cell.accessoryType = .disclosureIndicator
        } else {
          cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let d = masterList![indexPath.row] as! Dictionary<String, AnyObject>
        let a = d["children"]
        
        let txt = d["naicnum"] as! String
        let hasChildren = txt.count < 6
        
        if a != nil && hasChildren {
            if let nextController = storyboard?.instantiateViewController(withIdentifier: "rootview") as? NaicViewController {
                nextController.rawData = masterList![indexPath.row] as? Dictionary<String, AnyObject>
                nextController.navTitle = d["naicnum"] as! String
                nextController.headerText = d["title"] as! String

                navigationController?.pushViewController(nextController, animated: true)
            }
        } else {
           // let p = d["page"]
            print("END OF THE LINE")
           // performSegue(withIdentifier: "pdfdirect", sender: p)
        }
    }
    
    func presentEmailUI(_ bodyText:String, _ subject:String){
        
        print("Subject: " + subject)
        print("Body: " + bodyText)
        
        var subjectText = ""
        
        if subject == "NAIC Codes" {
            subjectText = "NAIC Code Index"
        } else {
            subjectText = "NAIC: " + subject
        }
        
        if MFMailComposeViewController.canSendMail() {
           Flurry.logEvent("Email UI Opened", withParameters: nil);
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setMessageBody(bodyText, isHTML: false)
            mailComposeViewController.setSubject(subjectText)
            
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let mailalert = UIAlertController(title: nil, message: "There appears to be no email account setup on this device.  Unable to send email", preferredStyle: .alert)
            
            mailalert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            
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
   
    @objc private func handleBookMarkChanges(notification: Notification) {
        tblView.reloadData()
    }
    
    @objc private func handleBookMarkAdded(notification: Notification) {
        showAlertMessage("added.")
        tblView.reloadData()
    }
    
    @objc private func handleBookMarkDeleted(notification: Notification) {
        showAlertMessage("deleted.")
        tblView.reloadData()
    }


  }
