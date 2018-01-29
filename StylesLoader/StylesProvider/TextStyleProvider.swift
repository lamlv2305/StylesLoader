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

    public func perform(with dict: [String: Any], on object: Any) {
        guard let label = object as? UILabel, let text = label.text else { return }

        var attributedDictionary: [NSAttributedStringKey: Any] = [:]

        for (key, value) in dict {
            guard let styleType = TypeSafeStype(rawValue: key) else { continue }

            switch styleType {
            case .textColor:
                guard let text = value as? String, let color = text.hexColor else {
                    continue
                }

                attributedDictionary[NSAttributedStringKey.foregroundColor] = color

            case .fontSize:
                let attributedFont = attributedDictionary[NSAttributedStringKey.font] as? UIFont
                var currentFont = attributedFont ?? UIFont.systemFont(ofSize: 14)

                if let size = value as? CGFloat, let newFont = UIFont(name: currentFont.fontName, size: size) {
                    currentFont = newFont
                }

                attributedDictionary[NSAttributedStringKey.font] = currentFont

            case .fontName:
                let attributedFont = attributedDictionary[NSAttributedStringKey.font] as? UIFont
                var currentFont = attributedFont ?? UIFont.systemFont(ofSize: 14)

                if let fontName = value as? String, let newFont = UIFont(name: fontName, size: currentFont.pointSize) {
                    currentFont = newFont
                }

                attributedDictionary[NSAttributedStringKey.font] = currentFont

            case .textAlign:
                guard let newValue = value as? Double,
                    let alignment = NSTextAlignment(rawValue: Int(newValue))
                    else { continue }

                let currentStyles = attributedDictionary[NSAttributedStringKey.paragraphStyle] as? NSMutableParagraphStyle
                let newStyles = currentStyles ?? NSMutableParagraphStyle()

                newStyles.alignment = alignment
                attributedDictionary[NSAttributedStringKey.paragraphStyle] = newStyles

            default:
                continue
            }
        }

        label.attributedText = NSMutableAttributedString(string: text, attributes: attributedDictionary)
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

