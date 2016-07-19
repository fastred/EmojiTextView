//
//  TextToEmojiMapping.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 19/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation

// Mapping of the regular text to emoji characters
public typealias TextToEmojiMapping = Dictionary<String, String>

// TODO: use real database
public func defaultTextToEmojiMapping() -> TextToEmojiMapping {
    return [ "heart" : "❤️",
             "airplane" : "✈️"]
}
