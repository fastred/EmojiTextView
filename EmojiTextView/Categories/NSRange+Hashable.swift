//
//  NSRange+Hashable.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 19/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation

extension NSRange: Hashable {
    public var hashValue: Int {
        return location ^ length
    }
}

extension NSRange: Equatable {}

public func ==(lhs: NSRange, rhs: NSRange) -> Bool {
    return lhs.location == rhs.location && lhs.length == rhs.length
}
