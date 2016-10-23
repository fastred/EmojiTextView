//
//  TextHighlighting.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 19/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import UIKit

// Object responsible for handling the highlighting of the text that's replaceable with an emoji.
public protocol TextHighlighting {

    // Highlights range of text in the text view that's replaceable with an emoji. completion closure has to be called when the highlighting finishes.
    func highlight(range: NSRange, inTextView textView: UITextView, completion: @escaping (_ finished: Bool) -> ())

    // Cancels highlighting that's in progress
    func cancel()
}
