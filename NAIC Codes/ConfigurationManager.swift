//
//  ConfigurationManager.swift
//  NAIC Codes
//
//  Created by Tom Meehan on 1/12/19.
//  Copyright © 2019 Thomas Meehan. All rights reserved.
//

import Foundation
import UIKit


class ConfigurationManager {

    static let shared = ConfigurationManager()
    
    private init(){
    
    }
    
    func tableCellFontSize()->CGFloat {
        let sw = screenWidth / scaleFactor
        
        if sw < 377 {
            return 15.0
        }
        
        if sw < 416 {
            return 17.0
        }
        
        return 20.0
    }

    func tableCellFont()->UIFont{
        let ffont = UIFont(name: "HelveticaNeue", size: tableCellFontSize())
        return ffont!
    }
  
    func iPADHeaderFont()->UIFont{
        let ffont = UIFont(name: "HelveticaNeue", size: 15.0)
        return ffont!
    }

    func tableViewBackGroundColor()->UIColor{
        
       let indx:CGFloat = 245.0
       return UIColor(red:indx / 255.0, green: indx / 255.0, blue: indx / 255.0, alpha: 1.0)
     }
    
    func tableSeparatorColor()->UIColor{
        return UIColor(red:76.0 / 255.0, green: 76.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
    }
}
