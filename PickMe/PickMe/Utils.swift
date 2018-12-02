//
//  Utils.swift
//  PickMe
//
//  Created by 凡 on 12/1/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import Foundation

let isGuest : Bool = {
    return (UserDefaults.standard.stringArray(forKey: "login") ?? [String]())[0] == "false"
}()

func getFav() -> [String]{
    return UserDefaults.standard.stringArray(forKey: "fav") ?? [String]()
}

func getTaken(_ semester : String) -> [String] {
    return UserDefaults.standard.stringArray(forKey: semester) ?? [String]()
}

func getMajorMinor() -> [String] {
    return UserDefaults.standard.stringArray(forKey: "majorMinor") ?? [String]()
}
