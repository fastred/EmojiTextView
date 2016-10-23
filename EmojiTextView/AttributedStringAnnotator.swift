//
//  AttributedStringAnnotator.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 20/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation

final class AttributedStringAnnotator {

    let mapping: TextToEmojiMapping
    let defaultAttributes: [String : AnyObject]
    let annotationKey: String

    init(mapping: TextToEmojiMapping, defaultAttributes: [String : AnyObject], annotationKey: String) {
        self.mapping = mapping
        self.defaultAttributes = defaultAttributes
        self.annotationKey = annotationKey
    }

    // Returns the string with annotationKey annotation for words that can be replaced with emojis.
    func annotatedAttributedString(fromAttributedString: NSAttributedString) -> (NSAttributedString, Bool) {

        let string = fromAttributedString.string as NSString
        let mutable = fromAttributedString.mutableCopy() as! NSMutableAttributedString

        var rangeToMatchMap: [NSRange : Match] = [:]
        var shouldCancelRunningHighlighter = false

        // Adds annotationKey attribute to all words in the string that can be replaced with emojis.
        string.enumerateSubstrings(in: string.range, options: .byWords) { (substring, substringRange, enclosingRange, stop) in

            if let substring = substring,
               let mapped = self.mapping[(substring as NSString).lowercased]?.first {

                let match = Match(string: substring as NSString, emoji: mapped as NSString)
                rangeToMatchMap[substringRange] = match
                
                let existingAttribute = mutable.attribute(self.annotationKey, at: substringRange.location, effectiveRange: nil)
                
                if existingAttribute == nil {
                    mutable.addAttribute(self.annotationKey, value: match, range: substringRange)
                }
            }
        }

        // Removes annotationKey attribute from parts of the string that were replaceable with emoji but aren't anymore.
        mutable.enumerateAttribute(annotationKey, in: string.range, options: []) { (value, range, stop) in
            guard let match = value as? Match else { return }

            if rangeToMatchMap[range] == nil {
                if match.transitionState == .running {
                    shouldCancelRunningHighlighter = true
                }

                mutable.removeAttribute(self.annotationKey, range: range)
            }
        }

        // Sets default formatting for parts of the string that don't have annotationKey attribute associated with them.
        for i in 0..<string.length {
            if mutable.attribute(annotationKey, at: i, effectiveRange: nil) == nil {
                let safeRange = NSIntersectionRange(NSMakeRange(i, 1), string.range)
                mutable.addAttributes(defaultAttributes, range: safeRange)
            }
        }

        return (mutable.copy() as! NSAttributedString, shouldCancelRunningHighlighter)
    }
}
