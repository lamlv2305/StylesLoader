//
//  StylesLoader.swift
//  StylesLoader
//
//  Created by Luong Van Lam on 01/13/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

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

import class Foundation.NSObject

extension NSObject: StylesLoaderCompatible { }

extension StylesLoader where Base: NSObject {
    @discardableResult public func loadStyles(
        _ styles: [String],
        extra value: Any? = nil,
        from resources: StylesResources = StylesResources.shared
    ) -> Base {
        resources.applyStyles(for: styles, on: base, extra: value)
        return base
    }

    @discardableResult public func loadStyles(
        _ style: String,
        extra value: Any? = nil,
        from resources: StylesResources = StylesResources.shared
    ) -> Base {
        resources.applyStyles(for: [style], on: base, extra: value)
        return base
    }
}
