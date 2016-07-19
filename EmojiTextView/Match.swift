//
//  Match.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 20/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation

/// `Match` class keeps information about a single word that can be replaced with an emoji.
class Match {
    /// State of the animated transition (highlighting).
    enum TransitionState {
        case NotStarted
        case Running
        case Completed
    }

    let string: NSString
    let emoji: NSString
    var transitionState = TransitionState.NotStarted

    init(string: NSString, emoji: NSString) {
        self.string = string
        self.emoji = emoji
    }
}
