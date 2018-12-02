//
//  Utils.swift
//  PickMe
//
//  Created by 凡 on 12/1/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import Foundation

func isLogIn() -> Bool{
    return (UserDefaults.standard.stringArray(forKey: "login") ?? [String]())[0] == "true"
}

func getFav() -> [String]{
    return UserDefaults.standard.stringArray(forKey: "fav") ?? [String]()
}

func getTaken(_ semester : String) -> [String] {
    return UserDefaults.standard.stringArray(forKey: semester) ?? [String]()
}

func getMajorMinor(_ index : Int) -> String {
    print(UserDefaults.standard.stringArray(forKey: "majorMinor") ?? [String]())
    return (UserDefaults.standard.stringArray(forKey: "majorMinor") ?? [String]())[index]
}

extension String {
    subscript(value: NSRange) -> Substring {
        return self[value.lowerBound..<value.upperBound]
    }
}

extension String {
    subscript(value: CountableClosedRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...index(at: value.upperBound)]
        }
    }
    
    subscript(value: CountableRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...]
        }
    }
    
    func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }
}
