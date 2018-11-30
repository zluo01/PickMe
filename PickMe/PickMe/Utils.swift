//
//  Utils.swift
//  MovieSearcher
//
//  Created by 凡 on 10/14/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import Foundation
import UIKit
import SwiftyPlistManager

// Todo initialize plist at the first starting pages

let plistName = "localData"

// global variable
var favorList : [String: [String: String]] = {
   return getFavorClass()
}()

var taken : [String:[String]] = {
    return getTaken()
}()

var guest : Bool = {
    return isGuest()
}()

func getFavorClass() -> [String: [String: String]] {
    if let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "favorClass", fromPlistWithName: plistName) {
        print("-------------> The Fetched Value for Key test actually exists. It is: '\(fetchedValue)'")
        return fetchedValue as! [String: [String: String]]
    }
    return [:]
}

func updateFavor(_ dict: [String: [String: String]]) {
    SwiftyPlistManager.shared.save(dict, forKey: "favorClass", toPlistWithName: plistName) { (err) in
        if err == nil {
            print("-------------> Value '\(dict)' successfully saved at favorClass into '\(plistName).plist'")
        }
    }
}

func getTaken() -> [String:[String]] {
    if let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "taken", fromPlistWithName: plistName) {
        print("-------------> The Fetched Value for Key test actually exists. It is: '\(fetchedValue)'")
        return fetchedValue as! [String: [String]]
    }
    return [:]
}

func updateTaken(_ dict: [String: [String: String]]){
    SwiftyPlistManager.shared.save(dict, forKey: "favorClass", toPlistWithName: plistName) { (err) in
        if err == nil {
            print("-------------> Value '\(dict)' successfully saved at taken into '\(plistName).plist'")
        }
    }
}

func getMajorMinors() -> [String]{
    if let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "mojorMinors", fromPlistWithName: plistName) {
        print("-------------> The Fetched Value for Key test actually exists. It is: '\(fetchedValue)'")
        return fetchedValue as! [String]
    }
    return []
}

func updateMajorMinors(_ majors : [String]) {
    
}

func isGuest() -> Bool {
    if let result = SwiftyPlistManager.shared.fetchValue(for: "guest", fromPlistWithName: plistName) {
        return result as! Bool
    }
    return false
}

func setGuest(_ setting: Bool) {
    SwiftyPlistManager.shared.save(setting, forKey: "guest", toPlistWithName: plistName) { (err) in
        if err == nil {
            print("-------------> Value '\(setting)' successfully saved at Key guest into '\(plistName).plist'")
        }
    }
}

