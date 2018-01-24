//
//  StylesLoader.swift
//  StylesLoader
//
//  Created by Luong Van Lam on 01/13/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

import class UIKit.UIView

public struct StylesLoader<Base> {
    /// Base object to apply styles
    public let base: Base

    /// Make extension wrapper with base object
    init(_ base: Base) {
        self.base = base
    }
}

public protocol StylesLoaderCompatible {
    associatedtype LoaderType
    var styles: StylesLoader<LoaderType> { get }
}

extension StylesLoaderCompatible {
    public var styles: StylesLoader<Self> {
        return StylesLoader(self)
    }
}

extension UIView: StylesLoaderCompatible { }

extension StylesLoader where Base: UIView {
    public func loadStyles(_ styles: [String], from resources: StylesResources = StylesResources.shared) {
        resources.applyStyles(for: styles, on: base)
    }

    public func loadStyles(_ style: String, from resources: StylesResources = StylesResources.shared) {
        resources.applyStyles(for: [style], on: base)
    }
}
