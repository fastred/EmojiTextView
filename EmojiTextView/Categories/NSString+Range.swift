//
//  NSString+Range.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 20/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation

extension NSString {
    public var range: NSRange {
        return NSRange(location: 0, length: self.length)
    }
}
