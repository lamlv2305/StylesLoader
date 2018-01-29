//
//  StylesProvider.swift
//  StylesLoader
//
//  Created by Luong Van Lam on 01/13/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit

public protocol StylesProvider {
    /// Get all keys of this provider
    var allKeys: [String] { get }

    /// Validate key and values
    func validate(styles: [String: Any]) throws

    /// Perform action with key and values
    func perform(with dict: [String: Any], on object: NSObject, extra value: Any?)
}
