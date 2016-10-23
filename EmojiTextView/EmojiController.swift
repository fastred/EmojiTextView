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

    fileprivate let textView: UITextView
    fileprivate let tapRecognizer: UITapGestureRecognizer
    fileprivate var annotator: AttributedStringAnnotator
    fileprivate static let emojiKey = "EmojiTextViewKey"

    // text to emoji mapping
    public var mapping: TextToEmojiMapping = defaultTextToEmojiMapping()

    // object responsible for highlighting the text that is replaceable with emoji
    fileprivate var currentTextHighlighter: TextHighlighting?
    // returns a new instance of `TextHighlighting` object
    public var textHighlightingFactory: () -> TextHighlighting = {
        return GradientTextHighlighter()
    }

    // NSAttributedString attributes for the regular text
    public var defaultAttributes: [String : AnyObject] = {
        return [NSForegroundColorAttributeName : UIColor.black,
                NSFontAttributeName : UIFont.systemFont(ofSize: 18)]
    }()

    public init(textView: UITextView) {
        self.textView = textView
        self.tapRecognizer = UITapGestureRecognizer()
        self.annotator = AttributedStringAnnotator(mapping: mapping, defaultAttributes: defaultAttributes, annotationKey: type(of: self).emojiKey)

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name:NSNotification.Name.UITextViewTextDidChange, object: textView)

        tapRecognizer.addTarget(self, action: #selector(didTap(_:)))
        tapRecognizer.delegate = self
        textView.addGestureRecognizer(tapRecognizer)
        textView.typingAttributes = defaultAttributes

        updateAfterTextChange()
    }

    deinit {
        currentTextHighlighter?.cancel()
    }

    @objc fileprivate func textDidChange(_ notification: Notification) {
        updateAfterTextChange()
    }

    fileprivate func updateAfterTextChange() {
        let (annotatedAttributedString, shouldCancel) = annotator.annotatedAttributedString(fromAttributedString: textView.attributedText)
        if shouldCancel {
            currentTextHighlighter?.cancel()
        }

        let selectedRange = textView.selectedRange
        textView.attributedText = annotatedAttributedString
        textView.selectedRange = selectedRange

        highlightIfNeeded()
    }

    fileprivate func highlightIfNeeded() {
        let string = textView.attributedText.string as NSString
        var toTransition: (NSRange, Match)?

        // Sets toTransition with first not started match unless some transition is currently running.
        textView.attributedText.enumerateAttribute(type(of: self).emojiKey, in: string.range, options: []) { (value, range, stop) in

            guard let match = value as? Match else { return }
            if match.transitionState == .running {
                stop.pointee = true
            } else if match.transitionState == .notStarted {
                toTransition = (range, match)
                stop.pointee = true
            }
        }

        if let (range, match) = toTransition {
            let textHighlighter = textHighlightingFactory()
            currentTextHighlighter = textHighlighter
            match.transitionState = .running

            textHighlighter.highlight(range: range, inTextView: textView, completion: { [weak self] (finished) in
                match.transitionState = .completed
                self?.highlightIfNeeded()
            })
        }
    }

    @objc fileprivate func didTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if let (range, match) = rangeAndMatch(atPoint: gestureRecognizer.location(in: textView)) , match.transitionState == .completed {
            let mutable = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            mutable.replaceCharacters(in: range, with: match.emoji as String)
            textView.attributedText = mutable.copy() as! NSAttributedString

            updateAfterTextChange()
        }
    }

    fileprivate func rangeAndMatch(atPoint: CGPoint) -> (NSRange, Match)? {
        guard !textView.attributedText.string.isEmpty else {
            return nil
        }

        let layoutManager = textView.layoutManager
        let characterIndex = layoutManager.characterIndex(for: atPoint, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        var longestRange: NSRange = NSMakeRange(0, 0)
        let attributes = textView.attributedText.attributes(at: characterIndex, longestEffectiveRange: &longestRange, in: (textView.attributedText.string as NSString).range)

        if NSLocationInRange(characterIndex, longestRange) {
            if let match = attributes[type(of: self).emojiKey] as? Match {
                return (longestRange, match)
            }
        }

        return nil
    }
}

extension EmojiController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        // Prevents visual glitches by disabling default UITextView's gesture recognizers
        // from working on words that can be replaced with emojis.
        return rangeAndMatch(atPoint: gestureRecognizer.location(in: textView)) != nil
    }
}
