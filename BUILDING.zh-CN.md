# macDownMod 编译与运行

这个分支基于 MacDown 0.7.3，增加了 `\[...\]` 块级公式和 `\(...\)` 行内公式的解析，并让“偏好设置”窗口在新版 macOS 上保持发布版的控件外观与页面切换动画。

## 环境

- 一台 Mac，安装完整的 Xcode、Git 和 Homebrew。
- 已获授权访问私有仓库 `git@github.com:teeSngRovn/macDownMod.git`，并配置好 GitHub SSH 密钥。
- 首次安装 Ruby gem、CocoaPods 依赖，以及预览中加载 MathJax 时，需要网络连接。

已验证的环境：macOS 26.6.2、Xcode 27.0、Ruby 4.0.7、Bundler 4.0.20。其他版本尚未逐一验证。项目提交了 `Gemfile.lock` 和 `Podfile.lock`，分别固定 Ruby 与 CocoaPods 依赖版本。

## 从零编译

先检查 `xcode-select -p` 是否指向完整的 Xcode，例如 `/Applications/Xcode.app/Contents/Developer`。如果指向 `CommandLineTools`，执行：

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

然后在终端执行：

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

`make` 会生成编辑器的 Markdown 解析器源码；首次编译前必须执行，否则 Xcode 会报缺少 `pmh_parser.c`。`CODE_SIGNING_ALLOWED=NO` 用于本机调试构建，无须开发者签名。编译产物位于 `Build/DerivedData/Build/Products/Debug/MacDown.app`。如果已经装好合适的 Ruby 和 Bundler，可跳过安装命令；如果克隆时没带子模块，先执行 `git submodule update --init --recursive`。

也可以执行完 `make` 后，用 Xcode 打开 `MacDown.xcworkspace`，选 `MacDown` scheme 运行。要打开的是 workspace，因为依赖由 CocoaPods 提供。

## 公式与外观

在“偏好设置 → Rendering”里启用 **TeX-like math syntax**。例如：

```text
\[
E = mc^2
\]

行内公式：\(a+b\)
```

预览通过 CDN 加载 MathJax，因此公式显示需要网络连接。编译时使用当前 Xcode 的 macOS SDK；链接时保留 10.15 SDK 兼容版本，让系统沿用 MacDown 0.7.3 的偏好设置样式和窗口切换动画。
