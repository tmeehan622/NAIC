//
//  FavoritesViewController.swift
//  NAIC Codes
//
//  Created by Tom Meehan on 1/9/19.
//  Copyright © 2019 Thomas Meehan. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var NoFavoritesLBL: UILabel!
    @IBOutlet weak var AboutPanel: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var cellFont:UIFont = ConfigurationManager.shared.tableCellFont()
    var tableBGColor:UIColor = ConfigurationManager.shared.tableViewBackGroundColor()
    var tableSepColor:UIColor = ConfigurationManager.shared.tableSeparatorColor()

    var bookMarks:Array<Dictionary<String, Any>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBookMarkChanges(notification:)), name: Notification.Name.bookMarksChanged, object: nil)
        
        bookMarks = BookmarkManager.shared.bookMarks
        navigationItem.title = "Favorites"
        
        tblView.backgroundColor = tableBGColor
        tblView.separatorColor = tableSepColor
     }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bookMarks = BookmarkManager.shared.bookMarks
        NoFavoritesLBL.isHidden = bookMarks.count > 0
        tblView.isHidden = bookMarks.count == 0
      }

    @IBAction func AboutAction(_ sender: UIButton) {
        performSegue(withIdentifier: "showabout", sender: sender)
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return bookMarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritecell", for: indexPath)
        
        let naicLBL = cell.contentView.viewWithTag(10) as! UILabel
        let titleLBL = cell.contentView.viewWithTag(11) as! UILabel
        
        naicLBL.font = cellFont
        titleLBL.font = cellFont
        
        naicLBL.text = bookMarks[indexPath.row]["naicnum"] as! String
        titleLBL.text = bookMarks[indexPath.row]["title"] as! String
        
        if naicLBL.text!.count < 6 {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
   
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bm   = BookmarkManager.shared.bookMarks[indexPath.row]
            let bmname = bm["naicnum"] as! String
            
            BookmarkManager.shared.deleteBookMarkWithName(bmname)
            bookMarks = BookmarkManager.shared.bookMarks
            tableView.deleteRows(at: [indexPath], with: .fade)
            bookMarks = BookmarkManager.shared.bookMarks

            NoFavoritesLBL.isHidden = bookMarks.count > 0
            tblView.isHidden = bookMarks.count == 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        var canSelect = true
        let  dict = bookMarks[indexPath.row] as Dictionary<String, AnyObject>
        
        let navTitle = dict["naicnum"] as! String
        let headerText = dict["title"] as! String
    
        if navTitle.count < 6 {
            canSelect = true
        } else {
            canSelect = false
        }

        if canSelect {
            if let nextController = storyboard?.instantiateViewController(withIdentifier: "rootview") as? NaicViewController {
                nextController.rawData    = dict
                nextController.navTitle   = navTitle
                nextController.headerText = headerText
                nextController.disableFarvoritesButton = true
                navigationController?.pushViewController(nextController, animated: true)
            }
        }
    }
        
    @objc private func handleBookMarkChanges(notification: Notification) {
        bookMarks = BookmarkManager.shared.bookMarks
        NoFavoritesLBL.isHidden = bookMarks.count > 0
        tblView.isHidden = bookMarks.count == 0

        tblView.reloadData()
    }
}


