//
//  StylesResources.swift
//  StylesLoader
//
//  Created by Luong Van Lam on 01/13/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit

public class StylesResourcesError: NSError {
    public init(_ description: String, code: Int = 500) {
        super.init(domain: "com.lamlv.stylesloader", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class StylesResources {
    public static let shared = StylesResources()
    private(set) var colors: [String: String] = [:]
    private(set) var fonts: [String: String] = [:]
    private(set) var styles: [String: Any] = [:]
    private(set) var customVariables: [String: Any] = [:]
    private(set) var providers: [StylesProvider] = []
    private(set) var fileName: String?

    enum ParserSymbol: String {
        case font = "@"
        case color = "$"
        case `class` = "."
        case custom = "~"
    }

    /// Register new provider to perform
    @discardableResult public func register(_ provider: StylesProvider) -> Self {
        guard styles.keys.count > 0 else {
            fatalError("You have to load themes before register a provider")
        }

        let newFields = provider.allKeys
        let existedFields = providers.map { $0.allKeys }.flatMap { $0 }
        let overrideFields = Set(newFields).intersection(Set(existedFields))

        guard overrideFields.count == 0 else {
            let msg = "Same keys already existed: \(overrideFields)"
            #if DEBUG
                fatalError(msg)
            #else
                print(msg)
                return self
            #endif
        }

        do {
            try provider.validate(styles: styles)
            providers.append(provider)
        } catch {
            #if DEBUG
                fatalError(error.localizedDescription)
            #else
                print(error.localizedDescription)
                return self
            #endif
        }

        return self
    }

    /// Load all styles config from files
    public func load(from fileName: String) {
        guard
            let bundle = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let jsonData = try? Data(contentsOf: bundle, options: []),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let dict = jsonObject as? [String: Any]
            else { return }

        self.fileName = fileName

        if let colorJSON = dict["color"] as? [String: String] {
            colors = validateColor(colorJSON)
        }

        if let fontJSON = dict["font"] as? [String: String] {
            fonts = validateFont(fontJSON)
        }

        if let customJson = dict["customVariables"] as? [String: Any] {
            customJson.keys.forEach({ (key) in
                if !key.hasPrefix(ParserSymbol.custom.rawValue) {
                    #if DEBUG
                        fatalError("Custom key is not a valid type")
                    #endif
                }
            })

            customVariables = customJson
        }

        if let styleJSON = dict["styles"] as? [String: Any] {
            let validatedStyles = validateStyles(styleJSON, colors: colors, fonts: fonts)
            styles = flatStyle(styles: validatedStyles)
        }
    }

    /// Get style properties after multi class
    func applyStyles(for className: [String], on view: UIView) {
        if providers.count == 0 {
            let msg = "[WARNING] Do not have any providers, try to registry one !"
            #if DEBUG
                fatalError(msg)
            #else
                return print(msg)
            #endif
        }

        if fileName == nil {
            let msg = "[WARNING] do not have any themes files to load"
            #if DEBUG
                fatalError(msg)
            #else
                return print(msg)
            #endif
        }

        var result: [String: Any] = [:]

        for key in className {
            guard let properties = styles[key] as? [String: Any] else {
                continue
            }

            for (key, value) in properties {
                result[key] = value
            }
        }

        for (key, value) in result {
            providers
                .first(where: { $0.allKeys.contains(key) })?
                .perform(with: key, value: value, on: view)
        }
    }

    /// Map all hex color strings to UIColor
    private func validateColor(_ themes: [String: String]) -> [String: String] {
        return themes.reduce([:]) { (dict, data) -> [String: String] in
            guard data.key.hasPrefix("$"), data.value.hexColor != nil else {
                #if DEBUG
                    fatalError("Not valid color: [key: \(data.key), value: \(data.value)]")
                #else
                    return dict
                #endif
            }

            var mutateDict = dict
            mutateDict[data.key] = data.value
            return mutateDict
        }
    }

    /// Validate font name
    private func validateFont(_ themes: [String: String]) -> [String: String] {
        return themes.reduce([:]) { (dict, data) -> [String: String] in
            guard data.key.hasPrefix("@"), UIFont(name: data.value, size: 13) != nil else {
                #if DEBUG
                    fatalError("Not valid font: [key: \(data.key), value: \(data.value)]")
                #else
                    return dict
                #endif
            }

            var mutateDict = dict
            mutateDict[data.key] = data.value
            return mutateDict
        }
    }

    /// Validate current style, type check
    private func validateStyles(
        _ themes: [String: Any],
        colors: [String: String],
        fonts: [String: String],
        parentClass: [String] = []
    ) -> [String: Any] {
        var result: [String: Any] = [:]
        for child in themes {
            if let value = child.value as? [String: Any] {
                var currentParent = parentClass
                if let parent = value["parent"] as? String {
                    currentParent.append(parent)
                }

                result[child.key] = validateStyles(
                    value,
                    colors: colors,
                    fonts: fonts,
                    parentClass: currentParent
                )

                continue
            }

            if let value = child.value as? String {
                if value.hasPrefix(ParserSymbol.color.rawValue), colors[value] == nil {
                    #if DEBUG
                        fatalError("Not define color for variable: \(value)")
                    #else
                        continue
                    #endif
                }

                if value.hasPrefix(ParserSymbol.font.rawValue), fonts[value] == nil {
                    #if DEBUG
                        fatalError("Not define font for variable: \(value)")
                    #else
                        continue
                    #endif
                }

                if value.hasPrefix(ParserSymbol.class.rawValue), parentClass.contains(value) {
                    let numberOfParentClass = parentClass.filter { $0 == value }
                    if numberOfParentClass.count > 1 {
                        #if DEBUG
                            fatalError("Loop on superclass on \(value). Inherit from: \(parentClass)")
                        #else
                            continue
                        #endif
                    }
                }

                if value.hasPrefix(ParserSymbol.custom.rawValue), customVariables[value] == nil {
                    #if DEBUG
                        fatalError("Not define custom variable: \(value)")
                    #else
                        continue
                    #endif
                }
            }

            result[child.key] = child.value
        }

        return result
    }

    /// Flatten style, all parent properties map to their childrens
    private func flatStyle(styles: [String: Any]) -> [String: Any] {
        var result = styles

        // flatten parent key
        for key in result.keys {
            guard let dict = result[key] as? [String: Any] else {
                continue
            }

            guard dict.keys.contains("parent"),
                let parentName = dict["parent"] as? String,
                parentName.hasPrefix(ParserSymbol.class.rawValue)
                else { continue }

            if styles.keys.contains(parentName) == false {
                #if DEBUG
                    fatalError("Found nothing with class : \(parentName)")
                #else
                    continue
                #endif
            }

            guard let currentStyle = styles[key] as? [String: Any] else {
                continue
            }

            var appliedStyle = dequeueStyle(styles: result, key: parentName)
            for (key, value) in currentStyle {
                appliedStyle[key] = value
                appliedStyle.removeValue(forKey: "parent")
            }
            result[key] = appliedStyle
        }

        // change variable to normal value
        for (key, value) in result {
            guard let dict = value as? [String: Any] else {
                continue
            }

            var mutateDict = dict
            for child in mutateDict {
                guard let text = child.value as? String else { continue }

                if text.hasPrefix(ParserSymbol.color.rawValue) {
                    mutateDict[child.key] = colors[text]
                }

                if text.hasPrefix(ParserSymbol.font.rawValue) {
                    mutateDict[child.key] = fonts[text]
                }

                if text.hasPrefix(ParserSymbol.custom.rawValue) {
                    mutateDict[child.key] = customVariables[text]
                }
            }

            result[key] = mutateDict
        }

        return result
    }

    /// Did you have any parent styles ?
    private func dequeueStyle(styles: [String: Any], key: String) -> [String: Any] {
        guard let dict = styles[key] as? [String: Any] else {
            return [:]
        }

        guard let parentName = dict["parent"] as? String else {
            return dict
        }

        return dequeueStyle(styles: styles, key: parentName)
    }
}

func jsonDebug(_ dict: [String: Any]) {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let text = String(data: jsonData, encoding: String.Encoding.ascii) ?? ""
        print("[JSON DICT] \(text)")
    } catch {
        print(error.localizedDescription)
    }
}
