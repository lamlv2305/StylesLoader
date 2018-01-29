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
        case lineHeight
        case unknown
    }

    public var allKeys: [String] {
        let myKeys: [TypeSafeStype] = [.textColor, .fontSize, .fontName, .textAlign, .lineHeight]
        return myKeys.flatMap { $0.rawValue }
    }

    public init() { }

    public func perform(with dict: [String: Any], on object: NSObject, extra value: Any?) {
        let selectorName = "setAttributedText:"
        let selector = Selector(selectorName)
        guard object.responds(to: selector) else {
            let msg = "\(object.classForCoder) do not respond to \(selectorName)"
            return fatalDebug(msg, or: ())
        }

        let font = extractFont(from: dict) ?? UIFont.systemFont(ofSize: 17)
        let paragraphStyle = extractParagraph(from: dict, with: font)

        var attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]

        /**
         *  Convert lineHeight of sketch/css to minimumLineHeight and baselineOffset
         */
        if paragraphStyle.minimumLineHeight > font.lineHeight {
            let offset = paragraphStyle.minimumLineHeight - font.lineHeight
            attributes[NSAttributedStringKey.baselineOffset] = offset * 0.25
        }

        if let textColor = dict[TypeSafeStype.textColor.rawValue] as? String,
            let color = textColor.hexColor {
            attributes[NSAttributedStringKey.foregroundColor] = color
        }

        guard attributes.keys.count > 0, let text = value as? String else { return }
        object.perform(selector, with: NSAttributedString(string: text, attributes: attributes))
    }

    private func extractFont(from dict: [String: Any]) -> UIFont? {
        var fontName: String?
        var fontSize: Double = 17

        if let fName = dict[TypeSafeStype.fontName.rawValue] as? String {
            fontName = fName
        }

        if let fSize = dict[TypeSafeStype.fontSize.rawValue] as? Double {
            fontSize = fSize
        }

        guard let safeFont = fontName else { return nil }
        return UIFont(name: safeFont, size: CGFloat(fontSize))
    }

    private func extractParagraph(from dict: [String: Any], with font: UIFont) -> NSParagraphStyle {
        let styles = NSMutableParagraphStyle()

        if let newValue = dict[TypeSafeStype.textAlign.rawValue] as? Double,
            let alignment = NSTextAlignment(rawValue: Int(newValue)) {
            styles.alignment = alignment
        }

        if let lineHeight = dict[TypeSafeStype.lineHeight.rawValue] as? Double {
            styles.minimumLineHeight = max(CGFloat(lineHeight), font.lineHeight)
//            styles.lineHeightMultiple = CGFloat(lineHeight) / font.lineHeight
        }

        return styles
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
        case .fontSize, .lineHeight:
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

