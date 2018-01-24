//
//  TextStyleProvider.swift
//  StylesLoader
//
//  Created by Luong Van Lam on 01/14/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit

public struct TextStyleProvider: StylesProvider {
    private enum TypeSafeStype: String {
        case textColor
        case fontSize
        case fontName
        case textAlign
        case unknown
    }

    public var allKeys: [String] {
        let myKeys: [TypeSafeStype] = [.textColor, .fontSize, .fontName, .textAlign]
        return myKeys.flatMap { $0.rawValue }
    }

    public init() { }

    public func perform(with key: String, value: Any, on object: Any) {
        guard
            let label = object as? UILabel,
            let styleType = TypeSafeStype(rawValue: key)
            else { return }

        switch styleType {
        case .textColor:
            guard let text = value as? String, let color = text.hexColor else {
                return
            }

            label.textColor = color

        case .fontSize:
            guard let currentFont = label.font,
                let size = value as? CGFloat,
                let newFont = UIFont(name: currentFont.fontName, size: size)
                else { return }

            label.font = newFont

        case .fontName:
            guard let currentFont = label.font,
                let fontName = value as? String,
                let newFont = UIFont(name: fontName, size: currentFont.pointSize)
                else { return }

            label.font = newFont

        case .textAlign:
            guard let newValue = value as? Double,
                let alignment = NSTextAlignment(rawValue: Int(newValue))
                else { return }

            label.textAlignment = alignment

        default:
            break
        }
    }

    public func validate(styles: [String: Any]) throws {
        for (key, value) in styles {
            guard let safeStyle = TypeSafeStype(rawValue: key) else {
                continue
            }

            try validateTypeSafe(style: safeStyle, value: value)
        }
    }

    private func validateTypeSafe(style: TypeSafeStype, value: Any) throws {
        switch style {
        case .fontName:
            if value is String { return }
        case .fontSize:
            if value is Double { return }
        case .textAlign:
            if value is Int { return }
        case .textColor:
            if let text = value as? String, text.hexColor != nil {
                return
            }

        default:
            return
        }

        throw StylesResourcesError("Not valid styles key : \(style.rawValue) - value: \(value)")
    }
}

