//
//  Rounter.swift
//  RelaxApp2
//
//  Created by Honglin Yi on 3/4/18.
//  Copyright © 2018 Honglin Yi. All rights reserved.
//

import Foundation
import UIKit

public typealias RouterParams = [String:Any]

//MARK: RounterController
/**
  If use HYRouter, all of viewcontrollers have to use this protocol
*/
public protocol RouterController:class {
    /**
    Accepted all the data passed by last Controller.
     
    For exmpale:
     ```
     var params:[String:Any]? {
         didSet {
             guard let params = params else { return }
             if params.keys.contains("videoUrl")
             { self.videoUrl = videoUrl }
          }
     }
     var videoUrl:String?
     ```
    */
    var params:[String:Any]? { get set }
}

public extension RouterController where Self:UIViewController {
    /**
     Init a ViewController
     
     - Parameter controllerName: for controller using storyboard, it's is storyboard id, for controller without storyboard, it's the classname
     */
    func initController(_ controllerName:String) -> RouterController? {
        var usedStoryBoard = false
        if controllerName.range(of:"Controller", options:.caseInsensitive) == nil {
            usedStoryBoard = true
            let crlName = controllerName + "Controller"
            let crlName2 = controllerName + "ViewController"
            if initControllerFromClassName(crlName) == nil &&
                initControllerFromClassName(crlName2) == nil {
                print(controllerName+" hasn't been develped")
                return nil
            }
        }
        //check the controller existence and use storyboard or not
        //must check, cause can't handle the exception from initStoryBoard
        
        guard let vc = getController(usedStoryBoard, controllerName)
                  else { return nil }
        return vc
    }
    
    /**
     Navigate to next ViewController
     
     - Parameter controllerName: for controller using storyboard, it's is storyboard id, for controller without storyboard, it's the classname
     - Parameter params: all the data that need to pass to the next ViewController
     - Parameter isPresent: yes for modal presentation, no for push navigation
    */
    func navigate(_ controllerName:String,
                  _ params:[String:Any]? = [String:Any](),
                  _ isPresent:Bool = true) {
        print("Navigated to "+controllerName+"Controller")
        guard let vc = initController(controllerName) else { return }
        if let paras = params { vc.params = paras }
        pushAndPre(isPresent, vc as! UIViewController)
    }

    private func pushAndPre(_ isPresent:Bool,_ vc:UIViewController) {
        if isPresent {
            self.present(vc, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func getController(_ isStoryBoard:Bool, _ identifier:String) -> RouterController? {
        if isStoryBoard {
            let vc:RouterController = initControllerFromStoryBoard(identifier)
            return vc
        } else {
            return initControllerFromClassName(identifier) as? RouterController
        }
    }
    
}

//MARK: UIVIewController init controller from storyboard or classname
public extension UIViewController {
    /**
     A convinient method from HYRouter, directly init the Controller by its ID
    */
    func initControllerFromStoryBoard<T>(_ identifier:String) -> T {
        let storyboard = UIStoryboard(name:identifier, bundle: nil)
        let pc:T = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return pc
    }
    
    fileprivate func initControllerFromClassName(_ identifier:String) -> UIViewController? {
        guard let myclass = stringClassFromString(identifier)
            as? UIViewController.Type else { return nil }
        let instance = myclass.init()
        return instance
    }
    
    private func stringClassFromString(_ className: String) -> AnyClass? {
        guard let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"]
            as? String else { return nil}
        let namespace2 = namespace.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil) //for app name like "Squezze It"
        let cls:AnyClass? = NSClassFromString("\(namespace2).\(className)")
        return cls
    }
    
}
