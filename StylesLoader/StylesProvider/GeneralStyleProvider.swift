//
//  GeneralStyleProvider.swift
//  StylesLoader
//
//  Created by Luong Van Lam on 01/14/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit

public struct GeneralStyleProvider: StylesProvider {
    private let uiColorKey: [String] = [
        "backgroundColor"
    ]

    private let cgColorKey: [String] = []
    private let doubleKey: [String] = []

    public var allKeys: [String] {
        return [uiColorKey, cgColorKey, doubleKey].flatMap { $0 }
    }

    public init() { }

    public func perform(with key: String, value: Any, on object: Any) {
        guard let view = object as? UIView else { return }
        let selector = Selector("set\(key.firstUppercased):")
        guard view.layer.responds(to: selector) else { return }

        var mutateValue: Any!

        if doubleKey.contains(key), let currentValue = value as? Double {
            mutateValue = currentValue
        }

        if uiColorKey.contains(key), let currentValue = value as? UIColor {
            mutateValue = currentValue
        }

        if cgColorKey.contains(key), let currentValue = value as? UIColor {
            mutateValue = currentValue.cgColor
        }

        guard let safeValue = mutateValue else { return }
        view.layer.perform(selector, with: safeValue)
    }

    public func validate(styles: [String: Any]) throws {
        for (key, value) in styles {
            guard uiColorKey.contains(key) else { continue }
            guard let text = value as? String, text.hexColor != nil else {
                throw StylesResourcesError("Error on parse color from key: \(key) - value: \(value)")
            }
        }
    }
}
