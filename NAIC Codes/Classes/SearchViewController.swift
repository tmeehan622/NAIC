//
//  SearchViewController.swift
//  NAIC Codes
//
//  Created by Tom Meehan on 1/9/19.
//  Copyright © 2019 Thomas Meehan. All rights reserved.
//

import UIKit

struct LineItem {
    let naic : String
    let title : String
}

class SearchViewController: UIViewController,  UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var AboutPanel: UIView!
   
    var cellFont:UIFont = ConfigurationManager.shared.tableCellFont()
    var tableBGColor:UIColor = ConfigurationManager.shared.tableViewBackGroundColor()
    var tableSepColor:UIColor = ConfigurationManager.shared.tableSeparatorColor()
    
    let appDelegate     = UIApplication.shared.delegate as! AppDelegate

    var fullTextList = [LineItem]()
    var filteredTextList = [LineItem]()
    var search:UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        tblView.backgroundColor = tableBGColor
        tblView.separatorColor = tableSepColor

        search = UISearchController(searchResultsController: nil)
        search!.delegate = self
        search!.searchResultsUpdater = self
        search!.obscuresBackgroundDuringPresentation = false
        search!.searchBar.scopeButtonTitles = ["NAIC", "TITLE", "BOTH"]
        search!.searchBar.delegate = self
        search!.searchBar.placeholder = "Searc NAIC"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "Search"
        initializeFullList()
  }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIForContent()
    }
    
    func updateUIForContent(){
        bgImageView.isHidden = filteredTextList.count > 0
    }
    
    func initializeFullList(){
        
        if let filepath = Bundle.main.path(forResource: "naics17", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let lines = contents.split(separator: "\n")
                
                for line in lines {
                    let array = line.components(separatedBy: "•")
                    let naic = array[0]
                    let title = array[1]
                    
                    let lineRec = LineItem(naic:naic, title:title)
                    fullTextList.append(lineRec)
               }
                
              } catch {
                // contents could not be loaded
            }
        } else {
            //print("fail")
        }
    }
    
    @IBAction func AboutAction(_ sender: UIButton) {
        performSegue(withIdentifier: "showabout", sender: sender)
    }
    
    func searchBarIsEmpty() -> Bool {
        return search!.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = search!.searchBar.selectedScopeButtonIndex != 0
        return search!.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        updateUIForContent()
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "BOTH") {
        filteredTextList.removeAll()
        filteredTextList = fullTextList.filter({( litem : LineItem) -> Bool in
            var sText = ""
            
            if(scope == "NAIC"){
              sText = litem.naic
            } else {
                if(scope == "TITLE"){
                    sText = litem.title
                } else {
                    sText = litem.naic + " " + litem.title
                }
              }
            return sText.lowercased().contains(searchText.lowercased())
        })
        tblView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for:search!)
    }
   
    func didDismissSearchController(_ searchController: UISearchController){
       //print("didDismissSearchController")
    }
    
    func didPresentSearchController(_ searchController: UISearchController){
       // print("didPresentSearchController")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
       // print("willDismissSearchController")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
       // print("willPresentSearchController")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             return filteredTextList.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchcell", for: indexPath)

        let naicLBL = cell.contentView.viewWithTag(10) as! UILabel
        let titleLBL = cell.contentView.viewWithTag(11) as! UILabel
       
        naicLBL.font = cellFont
        titleLBL.font = cellFont

        let  lineRec = filteredTextList[indexPath.row]
  
        naicLBL.text = lineRec.naic
        titleLBL.text = lineRec.title

        return cell
    }
    
    func search(key:String, in dict:[String:Any], completion:((Any) -> ())) {
        if let foundValue = dict[key] {
            completion(foundValue)
        } else {
            dict.values.enumerated().forEach {
                if let innerDict = $0.element as? [String:Any] {
                    let nn = innerDict["naicnum"] as! String
                    print(nn)
                    search(key: key, in: innerDict, completion: completion)
                }
            }
        }
    }

    func substringwith(_ sourceString:String, _ numchars:Int)->String {
        
        let indx1 = sourceString.index(sourceString.startIndex, offsetBy: numchars)
        let newStr = String(sourceString[..<indx1])
        
        return newStr
    }

    func dictHasKey(_ dict:Dictionary<String, AnyObject>, _ key:String)->Bool{
        if let _ = dict[key] {
            return true
        }
        else {
            return false
        }
    }

    func naicsDictionaryForCode(key:String)->Dictionary<String, AnyObject>?  {
        let c = key.count
        var k3 = ""
        var k4 = ""
        var k5 = ""
        var k6 = ""
        
        var D2:Dictionary<String, AnyObject>?
        var D3:Dictionary<String, AnyObject>?
        var D4:Dictionary<String, AnyObject>?
        var D5:Dictionary<String, AnyObject>?
        var D6:Dictionary<String, AnyObject>?

        let k2 = substringwith(key, 2)
        if c > 2 {
            k3 = substringwith(key, 3)
            if c > 3 {
              k4 = substringwith(key, 4)
                if c > 4 {
                  k5 = substringwith(key, 5)
                  if c > 5 {
                    k6 = substringwith(key, 6)
                 }
               }
            }
         }
     
        //D2 is the root level records with 2-digit codes
        D2 = appDelegate.rawData![k2] as? Dictionary<String, AnyObject>
        if D2 == nil {
           return D2
        }
        
        var children = D2!["children"] as! Array<AnyObject>
        
        if k3.count > 0 && children.count > 0 {
            for indx in 0 ..< children.count {
                let d = children[indx] as? Dictionary<String, AnyObject>
                let naic = d!["naicnum"] as! String
                if naic == k3 {
                  D3  = d
                   break
                }
            }
        } else {
            return D2
        }
            
        if k4.count > 0 {
            children = D3!["children"] as! Array<AnyObject>
           
            for indx in 0 ..< children.count {
                let d = children[indx] as? Dictionary<String, AnyObject>
                let naic = d!["naicnum"] as! String
                if naic == k4 {
                    D4  = d
                    break
                }
            }
        } else {
            return D3
        }
      
        if k5.count > 0 {
            children = D4!["children"] as! Array<AnyObject>
            
            for indx in 0 ..< children.count {
                let d = children[indx] as? Dictionary<String, AnyObject>
                let naic = d!["naicnum"] as! String
                if naic == k5 {
                    D5  = d
                    break
                }
            }
        } else {
           return D4
        }

        if k6.count > 0 {
            children = D5!["children"] as! Array<AnyObject>
            
            for indx in 0 ..< children.count {
                let d = children[indx] as? Dictionary<String, AnyObject>
                let naic = d!["naicnum"] as! String
                if naic == k6 {
                    D6  = d
                    break
                }
            }
        } else {
           return D5
        }
       return D6
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let  lineRec   = filteredTextList[indexPath.row]
        let  searchKey = lineRec.naic
        let  dict      = naicsDictionaryForCode(key:searchKey)
        
        if dict != nil {
            let navTitle = dict!["naicnum"] as! String
            let headerText = dict!["title"] as! String
            
            if let nextController = storyboard?.instantiateViewController(withIdentifier: "rootview") as? NaicViewController {
                nextController.rawData    = dict
                nextController.navTitle   = navTitle
                nextController.headerText = headerText
                
                navigationController?.pushViewController(nextController, animated: true)
            }
        } else {
            // let p = d["page"]
            print("END OF THE LINE")
            // performSegue(withIdentifier: "pdfdirect", sender: p)
        }
    }
}

