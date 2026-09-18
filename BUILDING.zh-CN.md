# macDownMod 编译与运行

macDownMod 基于开源 Markdown 编辑器 0.7.3 的代码，增加了 `\[...\]` 块级公式和 `\(...\)` 行内公式解析，并让“偏好设置”窗口在新版 macOS 上保持原版的控件外观与页面切换动画。应用、Xcode 工程、scheme 和命令行工具都使用 `macDownMod` 名称。

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
xcodebuild -workspace macDownMod.xcworkspace -scheme macDownMod -configuration Debug -derivedDataPath "$PWD/Build/DerivedData" CODE_SIGNING_ALLOWED=NO build
open Build/DerivedData/Build/Products/Debug/macDownMod.app
```

`make` 会生成编辑器的 Markdown 解析器源码；首次编译前必须执行，否则 Xcode 会报缺少 `pmh_parser.c`。`CODE_SIGNING_ALLOWED=NO` 用于本机调试构建，无须开发者签名。编译产物位于 `Build/DerivedData/Build/Products/Debug/macDownMod.app`。如果已经装好合适的 Ruby 和 Bundler，可跳过安装命令；如果克隆时没带子模块，先执行 `git submodule update --init --recursive`。

构建后的应用标识符是 `com.teesngrovn.macdownmod-debug`（Debug）或 `com.teesngrovn.macdownmod`（Release）。偏好设置和自定义样式存放在新的应用域与 `~/Library/Application Support/macDownMod/`，不会覆盖原版应用的数据。旧版自动更新源已移除。

也可以执行完 `make` 后，用 Xcode 打开 `macDownMod.xcworkspace`，选 `macDownMod` scheme 运行。要打开的是 workspace，因为依赖由 CocoaPods 提供。

## 公式与外观

在“偏好设置 → Rendering”里启用 **TeX-like math syntax**。例如：

```text
\[
E = mc^2
\]

行内公式：\(a+b\)
```

预览通过 CDN 加载 MathJax，因此公式显示需要网络连接。编译时使用当前 Xcode 的 macOS SDK；链接时保留 10.15 SDK 兼容版本，让系统沿用原版 0.7.3 的偏好设置样式和窗口切换动画。

## 自定义语法扩展

默认规则在仓库的 `macDownMod/Resources/Extensions/latex.syntax.json`，随 App 一起打包。要在已安装的 App 中增加或覆盖规则，把 `*.syntax.json` 放到 `~/Library/Application Support/macDownMod/SyntaxExtensions/`。同名文件会覆盖内置文件；将其中的 `enabled` 设为 `false` 可以关闭那组规则。修改后重新触发预览渲染即可生效。

例如，新建 `~/Library/Application Support/macDownMod/SyntaxExtensions/percent-math.syntax.json`：

```json
{
  "name": "Percent math",
  "enabled": true,
  "rules": [
    { "open": "%%", "close": "%%", "kind": "displayMath" }
  ]
}
```

之后 `%%E=mc^2%%` 会作为块级公式渲染。`open`、`close` 是普通字符串，不是正则表达式；`kind` 可取 `displayMath` 或 `inlineMath`。规则仅在“TeX-like math syntax”开启时应用，并会跳过代码围栏、缩进代码和行内代码。这里的语法扩展作用于 Markdown 渲染；macDownMod 原有的 `.plugin` 是菜单动作插件，不提供渲染回调。
