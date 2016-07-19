//
//  ViewController.swift
//  Example
//
//  Created by Arkadiusz Holko on 17/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var emojiController: EmojiController?

    override func viewDidLoad() {
        super.viewDidLoad()

        emojiController = EmojiController(textView: self.textView)
    }
}

