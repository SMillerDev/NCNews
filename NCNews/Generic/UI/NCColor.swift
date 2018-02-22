//
//  NCColor.swift
//  NCNews
//
//  Created by Sean Molenaar on 18/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit

class NCColor {
    static let ncDefault: UIColor = UIColor(hexString: "#0082C9", alpha: 1)
    static var custom: UIColor = {
        guard let color = UserDefaults.standard.string(forKey: DefaultConstants.colorKey) else {
            return NCColor.ncDefault
        }
        return UIColor(hexString: color, alpha: 1)
    }()

    static func set(_ color: String) {
        UserDefaults.standard.set(color, forKey: DefaultConstants.colorKey)
    }
}

extension UIColor {
    //Initializes a UIColor based off of a hex string
    convenience init(hexString: String, alpha: CGFloat) {
        var cleanHex: String!
        //Eliminate common prefixes
        if hexString.hasPrefix("#") {
            cleanHex = String(hexString.dropFirst())
        } else if hexString.hasPrefix("0x") {
            cleanHex = String(hexString.dropFirst(2))
        } else {
            cleanHex = hexString
        }

        //Check for correct length
        if cleanHex.count != 6 {
            self.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: alpha)
            return
        }
        let rString = cleanHex[0...1]
        let gString = cleanHex[2...3]
        let bString = cleanHex[4...5]

        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)

        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: alpha)
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
