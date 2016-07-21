//
//  TextToEmojiMapping.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 19/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation

// Mapping of the regular text to emoji characters
public typealias TextToEmojiMapping = [String : [String]]

public func defaultTextToEmojiMapping() -> TextToEmojiMapping {

    var mapping: TextToEmojiMapping = [:]

    func addKey(key: String, value: String, atBeginning: Bool) {
        // ignore short words because they're non-essential
        guard key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 2 else {
            return
        }

        if mapping[key] == nil {
            mapping[key] = []
        }

        if atBeginning {
            mapping[key]?.insert(value, atIndex: 0)
        } else {
            mapping[key]?.append(value)
        }
    }

    guard let path = NSBundle(forClass: EmojiController.self).pathForResource("emojis", ofType: "json"),
        let data = NSData(contentsOfFile: path),
        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
        let jsonDictionary = json as? NSDictionary else {
            return [:]
    }

    for (key, value) in jsonDictionary {
        if let key = key as? String,
            let dictionary = value as? Dictionary<String, AnyObject>,
            let emojiCharacter = dictionary["char"] as? String {

            // Dictionary keys from emojis.json have higher priority then keywords.
            // That's why they're added at the beginning of the array.
            addKey(key, value: emojiCharacter, atBeginning: true)

            if let keywords = dictionary["keywords"] as? [String] {
                for keyword in keywords {
                    addKey(keyword, value: emojiCharacter, atBeginning: false)
                }
            }
        }
    }

    return mapping
}
