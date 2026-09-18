# MacDown

This fork builds MacDown 0.7.3 with support for standard `\[...\]` display math and `\(...\)` inline math, and retains the release version's Preferences appearance and pane animation on recent macOS versions. [中文编译说明](BUILDING.zh-CN.md).

[![](https://img.shields.io/github/release/MacDownApp/macdown.svg)](http://macdown.uranusjr.com/download/latest/)
![Total downloads](https://img.shields.io/github/downloads/MacDownApp/macdown/latest/total.svg)
[![Build Status](https://travis-ci.org/MacDownApp/macdown.svg?branch=master)](https://travis-ci.org/MacDownApp/macdown)
[![Say Thanks!](https://img.shields.io/badge/SayThanks.io-%E2%98%BC-1EAEDB.svg)](https://saythanks.io/to/macdown)


MacDown is an open source Markdown editor for OS X, released under the MIT License. The author stole the idea from [Chen Luo](https://twitter.com/chenluois)’s [Mou](http://mouapp.com) so that people can make crappy clones.

Visit the [project site](http://macdown.uranusjr.com/) for more information, or download [MacDown.app.zip](http://macdown.uranusjr.com/download/latest/) directly from the [latest releases](https://github.com/MacDownApp/macdown/releases/latest) page.

## Install

[Download](http://macdown.uranusjr.com/download/latest/), unzip, and drag the app to Applications folder. MacDown is also available through [Homebrew Cask](https://caskroom.github.io/):

    brew cask install macdown

## License

MacDown is released under the terms of MIT License. You may find the content of the license [here](http://opensource.org/licenses/MIT), or inside the `LICENSE` directory.

You may find full text of licenses about third-party components in the `LICENSE` directory, or the **About MacDown** panel in the application.

The following editor themes and CSS files are extracted from [Mou](http://mouapp.com), courtesy of Chen Luo:

* Mou Fresh Air
* Mou Fresh Air+
* Mou Night
* Mou Night+
* Mou Paper
* Mou Paper+
* Tomorrow
* Tomorrow Blue
* Tomorrow+
* Writer
* Writer+
* Clearness
* Clearness Dark
* GitHub
* GitHub2

## Development

### Requirements

Use a Mac with full Xcode selected by `xcode-select`, Git, and Ruby with Bundler. This build was verified on macOS 26.6.2 with Xcode 27.0, Ruby 4.0.7, and Bundler 4.0.20. The committed `Gemfile.lock` pins the Ruby gems, and `Podfile.lock` pins the CocoaPods dependencies. Internet access is needed for the first dependency install and for MathJax rendering in the preview.

### Environment Setup

After configuring SSH access to the private repository, run:

```sh
git clone --recurse-submodules git@github.com:teeSngRovn/macDownMod.git
cd macDownMod
brew install ruby
export PATH="$(brew --prefix ruby)/bin:$PATH"
gem install bundler -v 4.0.20
bundle _4.0.20_ install
bundle exec pod install
make -C Dependency/peg-markdown-highlight
xcodebuild -workspace MacDown.xcworkspace -scheme MacDown -configuration Debug -derivedDataPath "$PWD/Build/DerivedData" CODE_SIGNING_ALLOWED=NO build
open Build/DerivedData/Build/Products/Debug/MacDown.app
```

Select the full Xcode installation if `xcode-select -p` points to Command Line Tools (for the standard installation: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`). The `make` step generates the editor's Markdown parser source, which Xcode requires before its first build. To build in Xcode, complete the steps through `make`, open `MacDown.xcworkspace`, select the `MacDown` scheme, and run it. Always use the workspace, since the project depends on CocoaPods. If the repository was cloned without `--recurse-submodules`, run `git submodule update --init --recursive` before building.

Enable **TeX-like math syntax** under Preferences → Rendering to render `\[...\]` and `\(...\)`. MathJax in the preview currently loads from a CDN.

The MacDown target compiles with the installed macOS SDK but links with a 10.15 SDK compatibility version. AppKit uses that version to retain the 0.7.3 preferences controls, toolbar appearance, and pane resize animation on newer macOS releases. If you remove the compatibility linker flag, review the preferences layout and appearance again.

## Discussion

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/MacDownApp/macdown)

Join our [Gitter channel](https://gitter.im/MacDownApp/macdown) if you have any problems with MacDown. Any suggestions are welcomed, too!

You can also [file an issue directly](https://github.com/MacDownApp/macdown/issues/new) on GitHub if you prefer so. But please, **search first to make sure no-one has reported the same issue already** before opening one yourself. MacDown does not update in your computer immediately when we make changes, so something you experienced might be known, or even fixed in the development version.

MacDown depends a lot on other open source projects, such as [Hoedown](https://github.com/hoedown/hoedown) for Markdown-to-HTML rendering, [Prism](http://prismjs.com) for syntax highlighting (in code blocks), and [PEG Markdown Highlight](https://github.com/ali-rantakari/peg-markdown-highlight) for editor highlighting. If you find problems when using those particular features, you can also consider reporting them directly to upstream projects as well as to MacDown’s issue tracker. I will do what I can if you report it here, but sometimes it can be more beneficial to interact with them directly.

## Tipping

If you find MacDown suitable for your needs, please consider [giving me a tip through PayPal](http://macdown.uranusjr.com/faq/#donation). Or, if you prefer to buy me a drink *personally* instead, just [send me a tweet](https://twitter.com/uranusjr) when you visit [Taipei, Taiwan](http://en.wikipedia.org/wiki/Taipei), where I live. I look forward to meeting you!
