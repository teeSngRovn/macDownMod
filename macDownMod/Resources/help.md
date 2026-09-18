# macDownMod 使用说明

macDownMod 在左侧编辑 Markdown，在右侧显示预览。可以通过“偏好设置”调整编辑器、预览样式和 Markdown 扩展。

## 常用 Markdown

~~~~markdown
# 标题

**粗体**、*斜体*、[链接](https://example.com)

- 列表项
- 第二项

```text
代码块
```
~~~~

## 数学公式

先在“偏好设置 → Rendering”中启用 **TeX-like math syntax**。块级公式使用 `\[...\]`：

```text
\[
E = mc^2
\]
```

行内公式使用 `\(a+b\)`。预览中的 MathJax 目前通过 CDN 加载，因此显示公式需要网络连接。

## 自定义语法

内置规则在应用资源的 `Extensions/latex.syntax.json`。将 `*.syntax.json` 放到 `~/Library/Application Support/macDownMod/SyntaxExtensions/` 可增加或覆盖规则；修改后重新触发预览渲染。规则格式及示例见仓库的 `README.zh-CN.md`。

代码围栏、缩进代码和行内代码中的公式定界符不会被语法扩展改写。

## 其他设置

- “Markdown”页控制表格、自动链接等语法扩展。
- “Rendering”页控制代码高亮、Mermaid、Graphviz、目录和数学公式。
- “Editor”页控制字体、主题、自动补全和滚动行为。
- “Terminal”页可以安装名为 `macDownMod` 的命令行工具。

项目的编译说明、许可及更多信息见仓库 README。
