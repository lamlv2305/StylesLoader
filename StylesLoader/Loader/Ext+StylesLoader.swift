//
//  Ext+StylesLoader.swift
//  StylesLoader
//
//  Created by Luong Van Lam on 01/13/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit

extension String {
    var hexColor: UIColor? {
        guard
            let regex = try? NSRegularExpression(pattern: "^#([A-Fa-f0-9]{8})$", options: []),
            regex.matches(in: self, options: [], range: NSMakeRange(0, self.count)).count > 0
            else { return fatalDebug("Not valid Color: \(self)", or: nil) }

        var cString = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard cString.hasPrefix("#") else {
            return fatalDebug("Not valid Color: \(self)", or: nil)
        }

        cString.remove(at: cString.startIndex)
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
            blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
            alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
        )
    }

    var firstUppercased: String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }
}

private var extraKey: Void?
extension NSObject {
    var stylesExtra: Any? {
        get { return objc_getAssociatedObject(self, &extraKey) }
        set { objc_setAssociatedObject(self, &extraKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

func fatalDebug<Type>(
    _ lastMessage: @autoclosure () -> String,
    or defaultObject: Type,
    file: StaticString = #file,
    line: UInt = #line
) -> Type {
    #if DEBUG
        fatalError(lastMessage(), file: file, line: line)
    #else
        print("\(file):\(line): \(lastMessage())")
        return defaultObject
    #endif
}
