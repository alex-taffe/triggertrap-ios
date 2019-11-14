//
//  Collection.swift
//  TriggertrapSLR
//
//  Created by Alex Taffe on 11/14/19.
//  Copyright © 2019 Triggertrap Limited. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

