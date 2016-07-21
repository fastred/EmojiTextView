//
//  GradientTextHighlighter.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 20/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import UIKit

public class GradientTextHighlighter: TextHighlighting {

    private var displayLink: CADisplayLink?

    public var animationDurationPerLetter: CGFloat = 0.06
    public var animationOverlap: CGFloat = 0.04

    private var startTime: CFTimeInterval = 0.0
    weak private var textView: UITextView?
    private var range: NSRange?
    private var completion: ((Bool) -> ())?

    public func highlightRange(range: NSRange, inTextView textView: UITextView, completion: (finished: Bool) -> ()) {
        self.textView = textView
        self.range = range
        self.completion = completion

        // Animation of text on iOS is in the dire state. There doesn't seem to any other way of animating text
        // that works with the default stack of UITextView.
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire(_:)))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        startTime = CACurrentMediaTime()
    }

    deinit {
        stopDisplayLink()
    }

    public func cancel() {
        stopDisplayLink()
    }

    private func stopDisplayLink() {
        displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink = nil
    }

    @objc private func displayLinkDidFire(displayLink: CADisplayLink) {
        guard let textView = textView, let range = range else {
            return
        }

        for i in 0..<range.length {
            let letterStartTime = CGFloat(i) * (animationDurationPerLetter - animationOverlap)
            let letterEndTime = letterStartTime + animationDurationPerLetter
            let elapsed = CGFloat(CACurrentMediaTime()) - CGFloat(startTime)
            let progress = max(min((elapsed - letterStartTime) / (letterEndTime - letterStartTime), 1), 0)

            let color = UIColor.blackColor().interpolateColorTo(UIColor.orangeColor(), progress: CGFloat(progress))

            let mutableAttributed = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            let string = mutableAttributed.string as NSString

            let letterRange = NSMakeRange(range.location + i, 1)
            let safeRange = NSIntersectionRange(letterRange, string.range)

            mutableAttributed.addAttribute(NSForegroundColorAttributeName, value: color, range: safeRange)
            textView.attributedText = mutableAttributed.copy() as! NSAttributedString

            if i == range.length - 1 && progress >= 1.0 {
                stopDisplayLink()
                completion?(true)
            }
        }
    }
}
