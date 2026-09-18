# macDownMod

macDownMod is a macOS Markdown editor based on an open source 0.7.3 codebase. It adds configurable LaTeX math delimiters, builds with current Xcode, and preserves the original Preferences appearance on recent macOS releases. [中文说明](README.zh-CN.md) · [中文编译说明](BUILDING.zh-CN.md)

## Features in this fork

- `\[...\]` display math and `\(...\)` inline math when **TeX-like math syntax** is enabled in Preferences → Rendering.
- Literal math delimiter rules in [`latex.syntax.json`](macDownMod/Resources/Extensions/latex.syntax.json). Add or override `*.syntax.json` files in `~/Library/Application Support/macDownMod/SyntaxExtensions/` without rebuilding; see the [Chinese guide](BUILDING.zh-CN.md#自定义语法扩展).
- A separate app identity, `macDownMod.app`, command line utility `macDownMod`, and Xcode workspace and scheme named `macDownMod`.
- No update feed pointing to a different application's releases.

## Build and run

This was verified on macOS 26.6.2 with Xcode 27.0, Ruby 4.0.7, and Bundler 4.0.20. Configure SSH access to the private repository and select the full Xcode installation with `xcode-select`.

```sh
git clone --recurse-submodules git@github.com:teeSngRovn/macDownMod.git
cd macDownMod
brew install ruby
export PATH="$(brew --prefix ruby)/bin:$PATH"
gem install bundler -v 4.0.20
bundle _4.0.20_ install
bundle exec pod install
make -C Dependency/peg-markdown-highlight
xcodebuild -workspace macDownMod.xcworkspace -scheme macDownMod -configuration Debug -derivedDataPath "$PWD/Build/DerivedData" CODE_SIGNING_ALLOWED=NO build
open Build/DerivedData/Build/Products/Debug/macDownMod.app
```

The `make` step generates a parser source file required before Xcode's first build. Open `macDownMod.xcworkspace` to build in Xcode. MathJax in the preview currently loads from a CDN, so rendering formulas requires an internet connection.

The app uses independent bundle identifiers (`com.teesngrovn.macdownmod` for Release and `com.teesngrovn.macdownmod-debug` for Debug) and stores user files under `~/Library/Application Support/macDownMod/`. It does not overwrite the original app's preferences or styles.

## License

Original and third party license notices remain in [`LICENSE/`](LICENSE/).
