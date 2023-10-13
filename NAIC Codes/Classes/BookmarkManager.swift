//
//  BookmarkManager.swift
//  NAIC Codes
//
//  Created by Tom Meehan on 1/11/19.
//  Copyright © 2019 Thomas Meehan. All rights reserved.
//

import Foundation


class BookmarkManager {
    
    
    static let shared = BookmarkManager()
    var bookMarks:Array<Dictionary<String, Any>> = []

    private init(){
        
        if bookMarkFileExists() {
        let plurl = fullURLForFileNamed(kBookmarkFileName)
            if plurl != nil {
                let rawData = Dictionary<String, Any>.contentsOf(path: plurl!)
                bookMarks = rawData["list"] as! Array<Dictionary<String, Any>>
            }
        }
     }
    
    
    
    func fullPathForFileNamed(_ fname:String)->String {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let docsDirect = paths[0]
        
        let docsUrl = URL(fileURLWithPath: docsDirect)
        let undofolder = docsUrl.appendingPathComponent(fname)
        let fullpath = undofolder.path
        
        return fullpath
    }
    
    func addBookMark(bm:Dictionary<String, Any>){
        
        bookMarks.append(bm)
        writePList()
        NotificationCenter.default.post(name:NSNotification.Name.bookMarksChanged, object: nil, userInfo:nil)
        NotificationCenter.default.post(name:NSNotification.Name.bookMarkAdded, object: nil, userInfo:nil)
  }
    
    func deleteBookMarkWithName(_ bmname:String){
        let c = bookMarks.count
        var foundIndex = -1

        for indx in 0 ..< c {
            let bm = bookMarks[indx]
            if bm["naicnum"] as! String == bmname {
                foundIndex = indx
                break
            }
        }
        
        if foundIndex > -1 {
            bookMarks.remove(at: foundIndex)
            writePList()
          // NotificationCenter.default.post(name:NSNotification.Name.bookMarksChanged, object: nil, userInfo:nil)
        }
    }
        
    func bookMarkWithName(_ bmname:String)->Dictionary<String, Any>? {
       
        var retBM:Dictionary<String, Any>?
        
        for bm in bookMarks {
            
            if bm["naicnum"] as! String == bmname{
                retBM = bm
            }
        }
        return retBM
    }

    func fullURLForFileNamed(_ fname:String)->URL? {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let docsDirect = paths[0]
        
        let docsUrl = URL(fileURLWithPath: docsDirect)
        let fileurl = docsUrl.appendingPathComponent(fname)
        
        return fileurl
    }
   
    func bookMarkFileExists()->Bool {
        let filepath = fullPathForFileNamed(kBookmarkFileName)
        var retVal = false
        
        let fileManager = FileManager.default
        
        if (fileManager.fileExists(atPath: filepath)) {
            retVal = true
        }
        return retVal
    }
    
    func deleteBookMarkFile()->Bool{
        
        let filepath = fullPathForFileNamed(kBookmarkFileName)
        var retVal = false
        
        let fileManager = FileManager.default
        
        if (fileManager.fileExists(atPath: filepath)) {
            do {
                try FileManager.default.removeItem(atPath: filepath)
                retVal = true
            }
            catch let error as NSError {
            }
        } else {
            retVal = true  // returning true indicates the file is gone... even if it wasn't there in the first place
        }
        
        return retVal
    }
   
      func writePList(){
        
        let filepath = fullPathForFileNamed(kBookmarkFileName)
        print(filepath)
        if deleteBookMarkFile(){
            let masterDict = ["list":bookMarks]
            
            let OutDict:NSDictionary = NSDictionary.init(dictionary: masterDict)
            OutDict.write(toFile: filepath, atomically: true)
        }
      }
 }
