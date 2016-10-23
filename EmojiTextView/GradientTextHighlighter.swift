//
//  GradientTextHighlighter.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 20/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import UIKit

open class GradientTextHighlighter: TextHighlighting {

    fileprivate var displayLink: CADisplayLink?

    open var animationDurationPerLetter: CGFloat = 0.06
    open var animationOverlap: CGFloat = 0.04

    fileprivate var startTime: CFTimeInterval = 0.0
    weak fileprivate var textView: UITextView?
    fileprivate var range: NSRange?
    fileprivate var completion: ((Bool) -> ())?

    open func highlight(range: NSRange, inTextView textView: UITextView, completion: @escaping (_ finished: Bool) -> ()) {
        self.textView = textView
        self.range = range
        self.completion = completion

        // Animation of text on iOS is in the dire state. There doesn't seem to any other way of animating text
        // that works with the default stack of UITextView.
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire(_:)))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        startTime = CACurrentMediaTime()
    }

    deinit {
        stopDisplayLink()
    }

    open func cancel() {
        stopDisplayLink()
    }

    fileprivate func stopDisplayLink() {
        displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        displayLink = nil
    }

    @objc fileprivate func displayLinkDidFire(_ displayLink: CADisplayLink) {
        guard let textView = textView, let range = range else {
            return
        }

        for i in 0..<range.length {
            let letterStartTime = CGFloat(i) * (animationDurationPerLetter - animationOverlap)
            let letterEndTime = letterStartTime + animationDurationPerLetter
            let elapsed = CGFloat(CACurrentMediaTime()) - CGFloat(startTime)
            let progress = max(min((elapsed - letterStartTime) / (letterEndTime - letterStartTime), 1), 0)

            let color = UIColor.black.interpolateColorTo(UIColor.orange, progress: CGFloat(progress))

            let mutableAttributed = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            let string = mutableAttributed.string as NSString

            let letterRange = NSMakeRange(range.location + i, 1)
            let safeRange = NSIntersectionRange(letterRange, string.range)

            mutableAttributed.addAttribute(NSForegroundColorAttributeName, value: color, range: safeRange)
            let selectedRange = textView.selectedRange
            textView.attributedText = mutableAttributed.copy() as! NSAttributedString
            textView.selectedRange = selectedRange

            if i == range.length - 1 && progress >= 1.0 {
                stopDisplayLink()
                completion?(true)
            }
        }
    }
}
