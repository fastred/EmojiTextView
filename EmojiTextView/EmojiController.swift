//
//  EmojiController.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 17/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import UIKit


final public class EmojiController: NSObject {

    private let textView: UITextView
    private let tapRecognizer: UITapGestureRecognizer
    private var annotator: AttributedStringAnnotator
    private static let emojiKey = "EmojiTextViewKey"

    // text to emoji mapping
    public var mapping: TextToEmojiMapping = defaultTextToEmojiMapping()

    // object responsible for highlighting the text that is replaceable with emoji
    private var currentTextHighlighter: TextHighlighting?
    // returns a new instance of `TextHighlighting` object
    public var textHighlightingFactory: () -> TextHighlighting = {
        return GradientTextHighlighter()
    }

    // NSAttributedString attributes for the regular text
    public var defaultAttributes: [String : AnyObject] = {
        return [NSForegroundColorAttributeName : UIColor.blackColor(),
                NSFontAttributeName : UIFont.systemFontOfSize(18)]
    }()

    public init(textView: UITextView) {
        // TODO: enable only when the emoji keyboard is selected?
        self.textView = textView
        self.tapRecognizer = UITapGestureRecognizer()
        self.annotator = AttributedStringAnnotator(mapping: mapping, defaultAttributes: defaultAttributes, annotationKey: self.dynamicType.emojiKey)

        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textDidChange(_:)), name:UITextViewTextDidChangeNotification, object: textView)

        tapRecognizer.addTarget(self, action: #selector(didTap(_:)))
        tapRecognizer.delegate = self
        textView.addGestureRecognizer(tapRecognizer)
        textView.typingAttributes = defaultAttributes

        updateAfterTextChange()
    }

    deinit {
        currentTextHighlighter?.cancel()
    }

    @objc private func textDidChange(notification: NSNotification) {
        updateAfterTextChange()
    }

    private func updateAfterTextChange() {
        let (annotatedAttributedString, shouldCancel) = annotator.annotateAttributedStringFromAttributedString(textView.attributedText)
        if shouldCancel {
            currentTextHighlighter?.cancel()
        }

        let selectedRange = textView.selectedRange
        textView.attributedText = annotatedAttributedString
        textView.selectedRange = selectedRange

        highlightIfNeeded()
    }

    private func highlightIfNeeded() {
        let string = textView.attributedText.string as NSString
        var toTransition: (NSRange, Match)?

        // Sets toTransition with first not started match unless some transition is currently running.
        textView.attributedText.enumerateAttribute(self.dynamicType.emojiKey, inRange: string.range, options: []) { (value, range, stop) in

            guard let match = value as? Match else { return }
            if match.transitionState == .Running {
                stop.memory = true
            } else if match.transitionState == .NotStarted {
                toTransition = (range, match)
                stop.memory = true
            }
        }

        if let (range, match) = toTransition {
            let textHighlighter = textHighlightingFactory()
            currentTextHighlighter = textHighlighter
            match.transitionState = .Running

            textHighlighter.highlightRange(range, inTextView: textView, completion: { [weak self] (finished) in
                match.transitionState = .Completed
                self?.highlightIfNeeded()
            })
        }
    }

    @objc private func didTap(gestureRecognizer: UITapGestureRecognizer) {
        if let (range, match) = rangeAndMatchAtPoint(gestureRecognizer.locationInView(textView)) where match.transitionState == .Completed {
            let mutable = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            mutable.replaceCharactersInRange(range, withString: match.emoji as String)
            textView.attributedText = mutable.copy() as! NSAttributedString

            updateAfterTextChange()
        }
    }

    private func rangeAndMatchAtPoint(point: CGPoint) -> (NSRange, Match)? {
        guard !textView.attributedText.string.isEmpty else {
            return nil
        }

        let layoutManager = textView.layoutManager
        let characterIndex = layoutManager.characterIndexForPoint(point, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        var longestRange: NSRange = NSMakeRange(0, 0)
        let attributes = textView.attributedText.attributesAtIndex(characterIndex, longestEffectiveRange: &longestRange, inRange: (textView.attributedText.string as NSString).range)

        if NSLocationInRange(characterIndex, longestRange) {
            if let match = attributes[self.dynamicType.emojiKey] as? Match {
                return (longestRange, match)
            }
        }

        return nil
    }
}

extension EmojiController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        // Prevents visual glitches by disabling default UITextView's gesture recognizers
        // from working on words that can be replaced with emojis.
        return rangeAndMatchAtPoint(gestureRecognizer.locationInView(textView)) != nil
    }
}
