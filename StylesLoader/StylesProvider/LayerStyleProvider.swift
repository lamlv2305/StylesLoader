//
//  LayerStyleProvider.swift
//  StylesLoader
//
//  Created by Luong Van Lam on 01/13/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit

public struct LayerStyleProvider: StylesProvider {
    fileprivate let uiColorKey: [String] = []
    fileprivate let cgColorKey: [String] = ["borderColor", "backgroundColor", "shadowColor"]
    fileprivate let cgSizeKey: [String] = ["shadowOffset"]
    fileprivate let doubleKey: [String] = [
        "cornerRadius", "borderWidth", "shadowRadius", "shadowOpacity"
    ]

    public var allKeys: [String] {
        return [uiColorKey, cgColorKey, doubleKey, cgSizeKey].flatMap { $0 }
    }

    public init() { }

    public func perform(with dict: [String: Any], on object: NSObject, extra value: Any?) {
        guard let view = object as? UIView else { return }
        for (key, value) in dict {
            if key.hasPrefix("shadow") {
                applyShadow(key: key, value: value, on: view)
                continue
            }

            let selector = Selector("set\(key.firstUppercased):")
            guard view.layer.responds(to: selector) else { continue }

            var mutateValue: Any!

            if doubleKey.contains(key), let currentValue = value as? Double {
                mutateValue = currentValue
            }

            if uiColorKey.contains(key), let currentValue = value as? String, let color = currentValue.hexColor {
                mutateValue = color
            }

            if cgColorKey.contains(key), let currentValue = value as? String, let color = currentValue.hexColor {
                mutateValue = color.cgColor
            }

            if cgSizeKey.contains(key), let currentValue = value as? String {
                mutateValue = CGSizeFromString(currentValue)
            }

            guard let safeValue = mutateValue else { continue }
            view.layer.perform(selector, with: safeValue)
        }
    }

    public func validate(styles: [String: Any]) throws {
        let colorKey = [uiColorKey, cgColorKey].flatMap { $0 }
        for (key, value) in styles {
            if colorKey.contains(key) {
                guard let type = value as? String, type.hexColor != nil else {
                    throw StylesResourcesError("Error on key: \(key) - value: \(value)")
                }

                continue
            }

            if doubleKey.contains(key) {
                guard value is Double else {
                    throw StylesResourcesError("Error on key: \(key) - value: \(value)")
                }

                continue
            }

            if cgSizeKey.contains(key) {
                guard value is String else {
                    throw StylesResourcesError("Error on key: \(key) - value: \(value)")
                }

                continue
            }
        }
    }

    /**
     *  Don't know excatly what we fail on this selector
     *  Selector("setShadowOffset:") and Selector("setShadowOpacity:")
     *  Need more research then return to `view.layer.perform(selector, with: safeValue)`
     */
    private func applyShadow(key: String, value: Any, on view: UIView) {
        let layer = view.layer

        if key == "shadowOpacity", let val = value as? Double {
            layer.shadowOpacity = Float(val)
        }

        if key == "shadowColor", let text = value as? String, let color = text.hexColor {
            layer.shadowColor = color.cgColor
        }

        if key == "shadowOffset", let text = value as? String {
            layer.shadowOffset = CGSizeFromString(text)
        }

        if key == "shadowRadius", let val = value as? Double {
            layer.shadowRadius = CGFloat(val)
        }

        if layer.masksToBounds == true {
            layer.masksToBounds = false
        }
    }
}
