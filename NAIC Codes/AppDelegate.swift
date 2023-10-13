//
//  AppDelegate.swift
//  NAIC Codes
//
//  Created by Tom Meehan on 1/9/19.
//  Copyright © 2019 Thomas Meehan. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rawData:Dictionary<String, AnyObject>?

    func printScreenSizes(){
        print("Screen Width: \(screenWidth)")
        print("Screen Height: \(screenHeight)")
        print("Scale Factor: \(scaleFactor)")
        print("Scale FactorN: \(scaleFactorNative)")
    }
    
    func listFonts(){
        for famName in UIFont.familyNames {
           print(famName)
            for fntName in UIFont.fontNames(forFamilyName: famName){
              print("\t" + fntName)
            }
            print(" ")
         }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        Flurry.startSession("SMM53PJKWR4JVJJWK74B", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(true)
            .withLogLevel(FlurryLogLevelAll))
        
        screenWidth = UIScreen.main.nativeBounds.width
        screenHeight = UIScreen.main.nativeBounds.height
        scaleFactor = UIScreen.main.scale
        scaleFactorNative = UIScreen.main.scale

        let path = Bundle.main.path(forResource: "naic", ofType: "plist")!
        let url = URL(fileURLWithPath: path)

        rawData = Dictionary<String, AnyObject>.contentsOf(path: url)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let status = UserDefaults.standard.integer(forKey: "termsAccepted")
        
        if(status != 100){
            let initialViewController: TermsViewController = mainStoryboard.instantiateViewController(withIdentifier: "termscontroller") as! TermsViewController
            self.window?.rootViewController = initialViewController
        } else {
            let initialViewController: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabcontroller") as! UITabBarController
            self.window?.rootViewController = initialViewController
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let docsDirect = paths[0]

        print(docsDirect)
        printScreenSizes()
        listFonts()
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func resumeNormalFlow(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabcontroller") as! UITabBarController
        self.window?.rootViewController = initialViewController
    }

    @objc func quitApplication(){
        //print("Quitting Application")
        exit(0)
    }

}

extension UIView{
    
    func addShadow(to edges:[UIRectEdge], radius:CGFloat){
        
        let toColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        let fromColor = UIColor(red: 188.0/255.0, green: 188.0/255.0, blue: 188.0/255.0, alpha: 1.0)
        // Set up its frame.
        let viewFrame = self.frame
        for edge in edges{
            let gradientlayer          = CAGradientLayer()
            gradientlayer.colors       = [fromColor.cgColor,toColor.cgColor]
            gradientlayer.shadowRadius = radius
            
            switch edge {
            case UIRectEdge.top:
                gradientlayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientlayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                gradientlayer.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: gradientlayer.shadowRadius)
            case UIRectEdge.bottom:
                gradientlayer.startPoint = CGPoint(x: 0.5, y: 1.0)
                gradientlayer.endPoint = CGPoint(x: 0.5, y: 0.0)
                gradientlayer.frame = CGRect(x: 0.0, y: viewFrame.height - gradientlayer.shadowRadius, width: viewFrame.width, height: gradientlayer.shadowRadius)
            case UIRectEdge.left:
                gradientlayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientlayer.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradientlayer.frame = CGRect(x: 0.0, y: 0.0, width: gradientlayer.shadowRadius, height: viewFrame.height)
            case UIRectEdge.right:
                gradientlayer.startPoint = CGPoint(x: 1.0, y: 0.5)
                gradientlayer.endPoint = CGPoint(x: 0.0, y: 0.5)
                gradientlayer.frame = CGRect(x: viewFrame.width - gradientlayer.shadowRadius, y: 0.0, width: gradientlayer.shadowRadius, height: viewFrame.height)
            default:
                break
            }
            self.layer.addSublayer(gradientlayer)
        }
    }
}

extension Dictionary {
    static func contentsOf(path: URL) -> Dictionary<String, AnyObject> {
        let data = try! Data(contentsOf: path)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
        
        return plist as! [String: AnyObject]
    }
}

extension Notification.Name {
    static let bookMarksChanged = Notification.Name("bookMarksChanged")
    static let bookMarkAdded = Notification.Name("bookMarkAdded")
    static let bookMarkDeleted = Notification.Name("bookMarkDeleted")
  }

