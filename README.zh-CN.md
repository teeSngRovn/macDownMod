# macDownMod

macDownMod 是一款 macOS Markdown 编辑器。当前版本以开源 0.7.3 代码为基础，增加了可配置的数学语法扩展，并修复了新版 Xcode 的编译问题和新版 macOS 上偏好设置窗口的外观。

## 这次修改

- App、Xcode 工程、scheme、命令行工具和用户数据目录统一使用 `macDownMod` 名称。
- 在“偏好设置 → Rendering”启用 **TeX-like math syntax** 后，预览支持 `\[...\]` 块级公式和 `\(...\)` 行内公式。
- 公式定界符写在 `macDownMod/Resources/Extensions/latex.syntax.json` 中。运行时可以从 `~/Library/Application Support/macDownMod/SyntaxExtensions/` 加载或覆盖 `*.syntax.json`，无需重新编译。
- 编译时不修改 CocoaPods 下载的 Hoedown 源码。渲染器在解析 Markdown 前，根据语法规则转换公式定界符；代码围栏、缩进代码和行内代码保持原样。
- 偏好设置窗口保留原版的控件样式和页面切换动画。链接阶段采用 10.15 SDK 兼容版本，编译仍使用当前 Xcode 的 SDK。
- 移除了指向上游发布版的自动更新源。

## 自定义公式语法

新建 `~/Library/Application Support/macDownMod/SyntaxExtensions/percent-math.syntax.json`：

```json
{
  "name": "Percent math",
  "enabled": true,
  "rules": [
    { "open": "%%", "close": "%%", "kind": "displayMath" }
  ]
}
```

重新触发预览渲染后，`%%E=mc^2%%` 就会按块级公式解析。`kind` 支持 `displayMath` 和 `inlineMath`；`open`、`close` 是普通字符串。同名用户文件会覆盖内置文件，设为 `"enabled": false` 可以关闭对应规则。数学语法仍受偏好设置里的 **TeX-like math syntax** 开关控制。

## 编译与运行

完整环境要求和逐条命令见 [编译说明](BUILDING.zh-CN.md)。核心步骤是克隆私有仓库及子模块，安装 Bundler 与 CocoaPods 依赖，执行 `make -C Dependency/peg-markdown-highlight` 生成解析器，再用 `macDownMod.xcworkspace` 的 `macDownMod` scheme 构建。Debug 产物为 `macDownMod.app`。

预览中的 MathJax 当前通过 CDN 加载，显示公式需要网络连接。新应用使用独立的 bundle ID 和 `~/Library/Application Support/macDownMod/`，不会覆盖原版应用的偏好设置或样式文件。

## 许可

项目及第三方组件的许可文本保留在 [`LICENSE/`](LICENSE/)；原作者的版权声明保持不变。
