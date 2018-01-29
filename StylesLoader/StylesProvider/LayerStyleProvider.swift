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
    fileprivate let cgColorKey: [String] = ["borderColor", "shadowColor", "backgroundColor"]
    fileprivate let doubleKey: [String] = ["cornerRadius", "borderWidth", "shadowRadius", "shadowOpacity"]

    public var allKeys: [String] {
        return [uiColorKey, cgColorKey, doubleKey].flatMap { $0 }
    }

    public init() { }

    public func perform(with dict: [String: Any], on object: Any) {
        guard let view = object as? UIView else { return }
        for (key, value) in dict {
            let selector = Selector("set\(key.firstUppercased):")
            guard view.layer.responds(to: selector) else { continue }

            var mutateValue: Any?

            if doubleKey.contains(key), let currentValue = value as? Double {
                mutateValue = currentValue
            }

            if uiColorKey.contains(key), let currentValue = value as? String, let color = currentValue.hexColor {
                mutateValue = color
            }

            if cgColorKey.contains(key), let currentValue = value as? String, let color = currentValue.hexColor {
                mutateValue = color.cgColor
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
        }
    }
}
