Pod::Spec.new do |spec|
  spec.name = "EmojiTextView"
  spec.version = "0.0.1"
  spec.summary = "Tap to swap out words with emojis. Inspired by Messages.app on iOS 10."
  spec.homepage = "https://github.com/fastred/EmojiTextView"
  spec.screenshot = "https://raw.githubusercontent.com/fastred/EmojiTextView/master/demo.gif"
  spec.license = "MIT"
  spec.author = { "Arkadiusz Holko" => "fastred@fastred.org" }
  spec.social_media_url = "https://twitter.com/arekholko"
  spec.source = { :git => "https://github.com/fastred/EmojiTextView.git", :tag => spec.version.to_s }
  spec.frameworks = ["UIKit"]
  spec.ios.deployment_target = "9.0"
  spec.source_files = "EmojiTextView/**/*.swift"
  spec.resources = ["EmojiTextView/Resources/emojis.json"]
end

